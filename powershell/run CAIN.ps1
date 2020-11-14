#
#A shit ton of functions
#

function Get-Sequence {
    echo "PNG sequence"
    echo "Make sure the png sequence don't have alpha channel"
    timeout 1 /nobreak >$null 2>&1
    $script:OGframes = Read-Host "Specify the png sequence directory "
    echo "Assigning png sequence folder..."
    timeout 1 /nobreak >$null 2>&1
    echo "PNG sequence assigned"
    timeout 2 /nobreak >$null 2>&1
}

function Get-VideoInput {
    md .\cache >$null 2>&1
    $script:videopath = Read-Host "Specify video directory(Skip if drag and droped) "
    if($videopath -eq ""){
        $script:videopath = $env:videopath
    }
    .\ffprobe.exe -v error -select_streams v -of default=noprint_wrappers=1:nokey=1 -show_entries stream=r_frame_rate -i $videopath > .\cache\rate 2>&1
    $script:rate = [IO.File]::ReadAllText(".\cache\rate")
    $alphan = Read-Host "Is input a gif?(y/n)"          #I got an error with if($alphan = ""), it will not work so I looped it
    echo "Initializing frame extraction..."
    if($alphan -eq "y"){
        .\ffmpeg.exe -loglevel quiet -i $videopath -c:v libx264 -preset veryslow -crf 0 .\cache\gif.mp4
        md .\cache\Original_frames >$null 2>&1
        .\ffmpeg.exe -loglevel quiet -i ".\cache\gif.mp4" ".\cache\Original_frames\%6d.png"
        del .\cache\gif.mp4
    }else{
        md .\cache\Original_frames >$null 2>&1
        .\ffmpeg.exe -loglevel quiet -i $videopath ".\cache\Original_frames\%6d.png"
    }
    $script:OGframes = ".\cache\Original_frames"
    echo "Frame extraction completed..."
    timeout 2 >$null 2>&1
}

function Do-Interpolation {
    echo ""
    # NOTE--Will probably change the engine selection with a doskey dropdown menu
    $engineselect = Read-Host "Want to use DAIN instead of CAIN?(y/n)"
    if($engineselect -eq "y"){
        #use dain
        timeout 1 >$null 2>&1
        $engine = "cdain"
        echo "Using DAIN engine (2x only)"
        $interpDAIN = "2x"
        $interpCAIN = "null"
    }else{
        #use cain
        timeout 1 >$null 2>&1
        $engine = "cain"
        echo "Using CAIN engine"
        #$interpCAIN = Read-Host "2x, 4x or 8x"
        #if($interpCAIN = ""){
        #   $interpCAIN = "2x"
        $interpCAIN = "2x"
        $interpDAIN = "null"
    }
    timeout 1 >$null 2>&1
    if($engine -eq "cain"){
        $splitsize = Read-Host "Split size (default=2048)"
        if($splitsize -eq ""){
            $splitsize = "2048"
        }
    }
    # engines start here
    if ($interpDAIN -eq "2x"){
        $script:framerate = "$rate * 2"
        md .\cache\Interpolated_frames_2x >$null 2>&1
        .\dain-ncnn-vulkan.exe -i "$OGframes" -o ".\cache\Interpolated_frames_2x" -t 256 -j 2:3:2
        $script:Iframes = ".\cache\Interpolated_frames_2x"
    }
    if ($interpCAIN -eq "2x"){
        $script:framerate = "$rate * 2"
        echo ""
        echo "2x interpolation"
        md .\cache\Interpolated_frames_2x >$null 2>&1
        .\cain-ncnn-vulkan.exe -i "$OGframes" -o ".\cache\Interpolated_frames_2x" -t $splitsize
        $script:Iframes = ".\cache\Interpolated_frames_2x"
   #}
    # will add 4x again later
   #if ($interpCAIN -eq "4x"){
   #    $script:framerate = "$rate * 4"
   #    echo "2x interpolation"
   #    md .\cache\Interpolated_frames_2x >$null 2>&1
   #    .\cain-ncnn-vulkan.exe -i $OGframes -o ".\cache\Interpolated_frames_2x" -j 3:3:3
   #}
    # will add 8x again later
   #if ($interpCAIN -eq "8x"){
   #    $script:framerate = "$rate * 8"
   #    echo "2x interpolation"
   #    md .\cache\Interpolated_frames_2x >$null 2>&1
   #    .\cain-ncnn-vulkan.exe -i $OGframes -o ".\cache\Interpolated_frames_2x" 
    echo "Frame interpolation completed..."
    timeout 2 >$null 2>&1
    }
}

function Do-Video{
    echo ""
    #NOTE--tbh most of this part might be better if replaced with doskey
    $ftv = Read-Host "Want to convert frames to video?(y/n)"
    timeout 1 >$null 2>&1
    if($ftv -eq "y" -or ""){
        $audio = Read-Host "Does input has audio?(y/n)"
        timeout 1 >$null 2>&1
        $gif = Read-Host "Want gif instead of video?(y/n)"
        timeout 1 >$null 2>&1
        # Start of ffmpeg convertion
        if($gif -eq "y"){
            $audio = null
            .\ffmpeg.exe -loglevel quiet -i $videopath -vf palettegen ".\cache\palette.png"
            .\ffmpeg.exe -loglevel quiet -framerate $framerate -i "$Iframes\%6d.png" -i ".\cache\palette.png" -filter_complex "[0:v][1:v] paletteuse" ".\FinalGIF.gif"
            echo "GIF exported, check out the folder for the result"
        }
        if($audio -eq "y"){
            $crf = Read-Host "Specify a CRF value (default=16)"
            if($crf -eq ""){
            $crf = "16"
            }
            .\ffmpeg.exe -loglevel quiet -framerate $framerate -i "$IFrames\%6d.png" -i $videopath -map 0:v -map 1:a -c:v libx264 -preset veryslow -crf $crf -c:a copy ".\FinalVideo.mp4"
            echo "Video exported, check out the folder for the result"
        }
        if($audio -eq "n" -or ""){
            $crf = Read-Host "Specify a CRF value (default=16)"
            if($crf -eq ""){
            $crf = "16"
            }
            .\ffmpeg.exe -loglevel quiet -framerate $framerate -i "$IFrames\%6d.png" -c:v libx264 -preset veryslow -crf $crf ".\FinalVideo.mp4"
            echo "Video exported, check out the folder for the result"
        }
    }
    timeout 2 >$null 2>&1
}

function Clear-Cache{
    $delcache = Read-Host "Want to delete cache?(y/n)"
    if($delcache -eq "y"){
    Remove-Item .\cache -Force  -Recurse -ErrorAction SilentlyContinue
    echo "Cache deleted"
    }else{
    echo "Ok..."
    }
    timeout 2 >$null 2>&1
}

#
# Main Script
#

Set-PSDebug -Trace 0
timeout 1 /nobreak >$null 2>&1
Write-Host "CAIN powershell" -ForegroundColor Yellow
Write-Host "Version 1" -ForegroundColor Yellow
timeout 1 /nobreak >$null 2>&1
Write-Host "Changelog: code transfered the code to powershell"
Write-Host "           FPS is now detected automatically"
Write-Host "           4x and 8x doesn't work for now"
timeout 1 /nobreak >$null 2>&1
Write-Host "Notes: some questions might not be able to  "
Write-Host "       skipped like before, just be careful "
timeout 1 /nobreak >$null 2>&1
Write-Host ""
Write-Host "It's not perfect but it does the job"
timeout 1 /nobreak >$null 2>&1
echo ""
$input = read-host "Want to use png sequence instead?(y/n)"
if($input -eq ""){
    $input = "n"
}
if($input -eq "y"){
    Get-Sequence 
}elseif($input -eq "n"){
    Get-VideoInput
}
Do-Interpolation
Do-Video
Clear-Cache
Write-Host ""
Write-Host "Thanks for wasting my time    " -BackgroundColor: DarkGreen -ForegroundColor: Gray
timeout 2 >$null 2>&1
Write-Host "                              " -BackgroundColor: DarkGreen
Write-Host "Script written by Katzenwerfer" -BackgroundColor: DarkGreen -ForegroundColor: Gray
Write-Host ""
Write-Host "Closing in 5" -ForegroundColor: Red
timeout 1 >$null 2>&1
Write-Host "           4" -ForegroundColor: Red
timeout 1 >$null 2>&1
Write-Host "           3" -ForegroundColor: Red
timeout 1 >$null 2>&1
Write-Host "           2" -ForegroundColor: Red
timeout 1 >$null 2>&1
Write-Host "           1" -ForegroundColor: Red
timeout 1 >$null 2>&1