param(
  [string]$OutDir = "assets/audio"
)

$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

function New-Wav16([string]$Path, [int]$SampleRate, [double[]]$Samples) {
  $bytesPerSample = 2
  $subchunk2Size = $Samples.Length * $bytesPerSample
  $chunkSize = 36 + $subchunk2Size
  $fs = [System.IO.File]::Open($Path, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write)
  $bw = New-Object System.IO.BinaryWriter($fs)
  try {
    $bw.Write([Text.Encoding]::ASCII.GetBytes('RIFF'))
    $bw.Write([int]$chunkSize)
    $bw.Write([Text.Encoding]::ASCII.GetBytes('WAVE'))
    $bw.Write([Text.Encoding]::ASCII.GetBytes('fmt '))
    $bw.Write([int]16)
    $bw.Write([int16]1)
    $bw.Write([int16]1)
    $bw.Write([int]$SampleRate)
    $bw.Write([int]($SampleRate * $bytesPerSample))
    $bw.Write([int16]$bytesPerSample)
    $bw.Write([int16]16)
    $bw.Write([Text.Encoding]::ASCII.GetBytes('data'))
    $bw.Write([int]$subchunk2Size)
    foreach ($s in $Samples) {
      $clamped = [Math]::Max(-1.0, [Math]::Min(1.0, $s))
      $bw.Write([int16]([Math]::Round($clamped * 32767)))
    }
  } finally {
    $bw.Dispose(); $fs.Dispose()
  }
}

$sampleRate = 22050
$musicDuration = 24.0
$musicCount = [int]($sampleRate * $musicDuration)
$music = New-Object 'double[]' $musicCount
$progression = @(
  @(261.63, 329.63, 392.00),
  @(220.00, 293.66, 369.99),
  @(196.00, 246.94, 329.63),
  @(233.08, 293.66, 349.23),
  @(261.63, 329.63, 392.00),
  @(220.00, 293.66, 349.23)
)
for ($i = 0; $i -lt $musicCount; $i++) {
  $t = $i / $sampleRate
  $step = [int]([Math]::Floor($t / 4.0)) % $progression.Count
  $local = $t % 4.0
  $env = 0.55 + 0.45 * [Math]::Sin([Math]::PI * [Math]::Min(1.0, $local / 3.8))
  $notes = $progression[$step]
  $value = 0.0
  foreach ($n in $notes) {
    $value += 0.17 * [Math]::Sin(2.0 * [Math]::PI * $n * $t)
    $value += 0.05 * [Math]::Sin(2.0 * [Math]::PI * ($n * 0.5) * $t)
  }
  $value += 0.03 * [Math]::Sin(2.0 * [Math]::PI * 523.25 * $t) * [Math]::Max(0.0, [Math]::Sin(2.0 * [Math]::PI * 0.5 * $t))
  $value += 0.02 * [Math]::Sin(2.0 * [Math]::PI * 659.25 * $t) * [Math]::Max(0.0, [Math]::Sin(2.0 * [Math]::PI * 0.25 * $t + 1.1))
  $fade = 1.0
  if ($t -lt 0.8) { $fade = $t / 0.8 }
  elseif ($t -gt ($musicDuration - 1.2)) { $fade = [Math]::Max(0.0, ($musicDuration - $t) / 1.2) }
  $music[$i] = $value * $env * $fade * 0.75
}
New-Wav16 (Join-Path $OutDir 'meadow_theme.wav') $sampleRate $music

$sfxDuration = 0.42
$sfxCount = [int]($sampleRate * $sfxDuration)
$sfx = New-Object 'double[]' $sfxCount
for ($i = 0; $i -lt $sfxCount; $i++) {
  $t = $i / $sampleRate
  $attack = [Math]::Min(1.0, $t / 0.03)
  $release = [Math]::Max(0.0, 1.0 - ($t / $sfxDuration))
  $env = $attack * $release * $release
  $freq = 420.0 - 180.0 * ($t / $sfxDuration)
  $crunch = [Math]::Sin(2.0 * [Math]::PI * $freq * $t)
  $bite = [Math]::Sin(2.0 * [Math]::PI * 140.0 * $t + 0.4)
  $click = if ($t -lt 0.08) { [Math]::Sin(2.0 * [Math]::PI * 900.0 * $t) * (1.0 - $t / 0.08) } else { 0.0 }
  $noise = (Get-Random -Minimum -1.0 -Maximum 1.0) * 0.12
  $sfx[$i] = ($crunch * 0.42 + $bite * 0.22 + $click * 0.22 + $noise) * $env
}
New-Wav16 (Join-Path $OutDir 'carrot_munch.wav') $sampleRate $sfx

$jumpDuration = 0.24
$jumpCount = [int]($sampleRate * $jumpDuration)
$jump = New-Object 'double[]' $jumpCount
for ($i = 0; $i -lt $jumpCount; $i++) {
  $t = $i / $sampleRate
  $env = [Math]::Min(1.0, $t / 0.01) * [Math]::Pow([Math]::Max(0.0, 1.0 - ($t / $jumpDuration)), 1.8)
  $sweep = 720.0 + 180.0 * [Math]::Exp(-7.0 * $t)
  $tone = [Math]::Sin(2.0 * [Math]::PI * $sweep * $t)
  $air = [Math]::Sin(2.0 * [Math]::PI * 1200.0 * $t) * [Math]::Exp(-18.0 * $t)
  $jump[$i] = ($tone * 0.55 + $air * 0.18) * $env
}
New-Wav16 (Join-Path $OutDir 'rabbit_jump.wav') $sampleRate $jump

Write-Host "Generated audio in $OutDir"

