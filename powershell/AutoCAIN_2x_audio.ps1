#
#A shit ton of functions
#

function Get-VideoInput {
    md .\cache >$null 2>&1
    $script:videopath = $env:videopath
    .\ffprobe.exe -v error -select_streams v -of default=noprint_wrappers=1:nokey=1 -show_entries stream=r_frame_rate -i $videopath > cache\rate 2>&1
    $script:rate = [IO.File]::ReadAllText(".\cache\rate")
    echo "Initializing frame extraction..."
    timeout 1 >$null 2>&1
    md .\cache\Original_frames >$null 2>&1
    .\ffmpeg.exe -loglevel quiet -i $script:videopath ".\cache\Original_frames\%6d.png"
    echo "Frame extraction completed..."
    timeout 1 >$null 2>&1
}

function Do-Interpolation {
    echo ""
    timeout 1 >$null 2>&1
    $splitsize = "2048"
    # engines start here
    $script:framerate = "$rate * 2"
    echo ""
    echo "2x interpolation"
    md .\cache\Interpolated_frames_2x >$null 2>&1
    .\cain-ncnn-vulkan.exe -i ".\cache\Original_frames" -o ".\cache\Interpolated_frames_2x" -t $splitsize -j 3:4:3
    echo "Frame interpolation completed..."
    timeout 1 >$null 2>&1
}

function Do-Video{
    echo ""
    echo "Generating video, please wait..."
    timeout 1 >$null 2>&1
    .\ffmpeg.exe -loglevel quiet -framerate $framerate -i ".\cache\Interpolated_frames_2x\%06d.png" -c:v libx264 -preset veryslow -crf 16 ".\FinalVideo.mp4"
    .\ffmpeg.exe -loglevel quiet -framerate $framerate -i ".\cache\Interpolated_frames_2x\%6d.png" -i $script:videopath -map 0:v -map 1:a -c:v libx264 -preset veryslow -crf 16 -c:a copy ".\Audio_FinalVideo.mp4"
    echo "Video exported, check out the folder for the result"
    timeout 1 >$null 2>&1
}

function Clear-Cache{
    Remove-Item .\cache -Force  -Recurse -ErrorAction SilentlyContinue
    del .\rate >$null 2>&1
    echo "Cache deleted"
}

#
# Main Script
#

#this is the body of the script
Set-PSDebug -Trace 0
timeout 1 /nobreak >$null 2>&1
Write-Host "AutoCAIN powershell" -ForegroundColor Yellow
Write-Host "Version 1" -ForegroundColor Yellow
timeout 1 /nobreak >$null 2>&1
Get-VideoInput
Do-Interpolation
Do-Video
Clear-Cache
Write-Host ""
Write-Host "Thanks for wasting my time    " -BackgroundColor: DarkGreen -ForegroundColor: Gray
timeout 1 >$null 2>&1
Write-Host "                              " -BackgroundColor: DarkGreen
Write-Host "Script written by Katzenwerfer" -BackgroundColor: DarkGreen -ForegroundColor: Gray
timeout 1 >$null 2>&1
Write-Host ""
Write-Host "Closing in 3" -ForegroundColor: Red
timeout 1 >$null 2>&1
Write-Host "           2" -ForegroundColor: Red
timeout 1 >$null 2>&1
Write-Host "           1" -ForegroundColor: Red
timeout 1 >$null 2>&1