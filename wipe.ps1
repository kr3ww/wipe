# Số lần ghi đè
$numberOfOverwrites = 3

if ($args.Count -eq 0) {
    $directory = "D:\test\222"  # Giá trị mặc định nếu không có tham số được cung cấp
} else {
    $directory = $args[0]
}
# Kiểm tra xem thư mục có tồn tại không
if (-not (Test-Path -Path $directory -PathType Container)) {
    Write-Error "Not found: $directory"
    exit
}

# Tìm tất cả các tệp và thư mục con trong thư mục cụ thể
$files = Get-ChildItem -Path $directory -File -Recurse

foreach ($file in $files) {
    # Sử dụng handle.exe để hiển thị các tiến trình đang sử dụng tệp tin và lọc PID của các tiến trình
    $processIds = & ".\utils\handle.exe" -a $file.FullName | Select-String -Pattern "pid: (\d+)" | ForEach-Object { $_.Matches.Groups[1].Value }

    # Tắt các tiến trình sử dụng tệp tin
    if ($processIds) {
        foreach ($processId in $processIds) {
            Stop-Process -Id $processId -Force
            Write-Output " ID $processId use $file -> killed."
        }
    } else {
        Write-Output "not process use: $file."
    }

    # Ghi đè nhiều lần lên tệp tin
    for ($i = 1; $i -le $numberOfOverwrites; $i++) {
        $randomBytes = New-Object byte[] $file.Length
        (New-Object System.Security.Cryptography.RNGCryptoServiceProvider).GetBytes($randomBytes)
        [System.IO.File]::WriteAllBytes($file.FullName, $randomBytes)
        Write-Output "$i write ->  $file."
    }

    # Xoá tệp tin
    Remove-Item $file.FullName -Force
    Write-Output " $file -> deleted."
}

Remove-Item $directory -Recurse -Force
