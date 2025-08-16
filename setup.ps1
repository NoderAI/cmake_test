# ------------------------------
# MSVC + Ninja + CMake build script
# ------------------------------


# Path to your Visual Studio 2022 installation
$vsPath = "C:\Program Files\Microsoft Visual Studio\2022\Community"

# Path to the vcvarsall.bat file
$vcvarsPath = Join-Path $vsPath "VC\Auxiliary\Build\vcvarsall.bat"

# Architecture to set up (x64, x86, x64_x86, etc.)
$arch = "x64"

# Check if vcvarsall.bat exists
if (-Not (Test-Path $vcvarsPath)) {
    Write-Error "vcvarsall.bat not found at $vcvarsPath"
    exit 1
}

# Run vcvarsall.bat and capture environment variables
$envVars = cmd /c "`"$vcvarsPath`" $arch && set"

# Parse and apply environment variables to current PowerShell session
$envVars -split "`r?`n" | ForEach-Object {
    if ($_ -match "^(.*?)=(.*)$") {
        $name = $matches[1]
        $value = $matches[2]
        [System.Environment]::SetEnvironmentVariable($name, $value, "Process")
    }
}

Write-Host "Visual Studio 2022 environment variables set for $arch."


# Create build folder
if (-Not (Test-Path "build")) {
    mkdir build
}

# Run CMake with MinGW Makefiles
Write-Host "Running CMake..."
cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -G Ninja
cmake --build build

# Build the project
Write-Host "Building project..."
cmake --build build

Write-Host "Build complete! compile_commands.json should be in the build folder."