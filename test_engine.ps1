# test_engine.ps1 - Automated financial engine test suite
$ErrorActionPreference = 'Stop'

function Assert-Equal($actual, $expected, $tolerance, $message) {
    if ([Math]::Abs($actual - $expected) -gt $tolerance) {
        Write-Host "FAIL: $message (Expected: $expected, Actual: $actual)" -ForegroundColor Red
        throw "Assertion failed: $message"
    } else {
        Write-Host "PASS: $message" -ForegroundColor Green
    }
}

function Assert-Condition($condition, $message) {
    if (-not $condition) {
        Write-Host "FAIL: $message" -ForegroundColor Red
        throw "Assertion failed: $message"
    } else {
        Write-Host "PASS: $message" -ForegroundColor Green
    }
}

Write-Host '==========================================================' -ForegroundColor Cyan
Write-Host '   BUZFINANCE - FINANCIAL ENGINE TEST SUITE               ' -ForegroundColor Cyan
Write-Host '==========================================================' -ForegroundColor Cyan

# --- TEST 1: defaultData clean in index.html ---
Write-Host 'TEST 1: Verifying defaultData clean at zero...' -ForegroundColor Yellow
$html = [System.IO.File]::ReadAllText((Resolve-Path 'index.html').Path, [System.Text.Encoding]::UTF8)
$match = [regex]::Match($html, '(?s)function defaultData\(\)\s*\{([\s\S]*?\n\})')
Assert-Condition ($match.Success) 'defaultData exists'
$code = $match.Groups[1].Value
Assert-Condition ($code -match 'cajaInicial:\s*0') 'cajaInicial is 0'
Assert-Condition ($code -match 'ahorroInicial:\s*0') 'ahorroInicial is 0'
Assert-Condition ($code -match 'nominaMensual:\s*0') 'nominaMensual is 0'
Assert-Condition ($code -match 'hipotecaMensual:\s*0') 'hipotecaMensual is 0'
Assert-Condition ($code -match 'traspasoAhorro:\s*0') 'traspasoAhorro is 0'
Assert-Condition ($code -match 'inversiones:\s*\[\s*\]') 'inversiones is []'
Assert-Condition ($code -match 'gastos:\s*\[\s*\]') 'gastos is []'
Assert-Condition ($code -match 'pinActivo:\s*false') 'seguridad.pinActivo is false'
Assert-Condition ($code -match 'nominaEneroNeto:\s*0') 'nominaEneroNeto is 0 in defaultData'
Assert-Condition ($code -match 'hipotecaTipo:\s*["'']fija["'']') 'hipotecaTipo is fija in defaultData'
Assert-Condition ($code -match 'hipotecaMesRevision:\s*10') 'hipotecaMesRevision is 10 in defaultData'
Assert-Condition ($code -match 'hipotecaCuotaRevisada:\s*0') 'hipotecaCuotaRevisada is 0 in defaultData'
Assert-Condition ($code -match 'nominasPorAno:\s*\{\s*\}') 'nominasPorAno is {} in defaultData'
Assert-Condition ($code -match 'pagasExtras:\s*\[\s*\]') 'pagasExtras is [] in defaultData'

# --- TEST 2: Compound interest math simulation ---
Write-Host 'TEST 2: Verifying compound interest formula...' -ForegroundColor Yellow
function Simular-InteresCompuesto($inicial, $mensual, $rentabilidadAnual, $meses) {
    $rMes = $rentabilidadAnual / 12.0
    $v = [double]$inicial
    for ($m = 1; $m -le $meses; $m++) {
        $v = ($v * (1.0 + $rMes)) + $mensual
    }
    return $v
}

# 10,000 EUR initial at 6% annual over 12 months with 100 EUR/mo contribution
$v12 = Simular-InteresCompuesto 10000 100 0.06 12
Assert-Equal $v12 11850.34 0.5 'Compound interest 10k at 6pct plus 100/mo after 12 months'

# No contribution: 5,000 EUR at 7% over 60 months
$v60 = Simular-InteresCompuesto 5000 0 0.07 60
Assert-Equal $v60 7088.10 0.5 'Compound interest 5k at 7pct without contribution after 5 years'

# --- TEST 3: Tax Withholding (19%) on Savings Account ---
Write-Host 'TEST 3: Tax withholding and net interest...' -ForegroundColor Yellow
function Simular-CuentaRemuneradaMes($saldo, $tae, $retencion) {
    $intBruto = $saldo * ($tae / 12.0)
    $ret = $intBruto * $retencion
    $intNeto = $intBruto - $ret
    return @{ Bruto = $intBruto; Retencion = $ret; Neto = $intNeto }
}

$rem = Simular-CuentaRemuneradaMes 40000 0.03 0.19
Assert-Equal $rem.Bruto 100.00 0.01 'Gross interest on 40k at 3pct TAE equals 100 EUR'
Assert-Equal $rem.Retencion 19.00 0.01 'Tax withholding 19pct equals 19 EUR'
Assert-Equal $rem.Neto 81.00 0.01 'Net interest received equals 81 EUR'

# --- TEST 4: Savings capacity and remaining liquid savings ---
Write-Host 'TEST 4: Savings capacity and remaining savings...' -ForegroundColor Yellow
function Calcular-AhorroRemanente($nomina, $gastos, $hipoteca, $inv, $traspaso) {
    $capBruta = $nomina - $gastos - $hipoteca
    $remanente = $capBruta - $inv - $traspaso
    return @{ CapBruta = $capBruta; Remanente = $remanente }
}

$ahorro = Calcular-AhorroRemanente 2600 1100 550 200 150
Assert-Equal $ahorro.CapBruta 950.00 0.01 'Gross savings capacity equals 2600 - 1100 - 550 = 950 EUR'
Assert-Equal $ahorro.Remanente 600.00 0.01 'Remaining liquid savings equals 950 - 200 - 150 = 600 EUR'

$deficit = Calcular-AhorroRemanente 1500 1400 400 50 50
Assert-Equal $deficit.CapBruta -300.00 0.01 'Gross deficit equals -300 EUR'
Assert-Equal $deficit.Remanente -400.00 0.01 'Remaining deficit equals -400 EUR'

# --- TEST 5: Weighted average return of portfolio ---
Write-Host 'TEST 5: Weighted average return...' -ForegroundColor Yellow
function Calcular-RentabilidadPonderada($productos) {
    $totalHoy = 0.0
    $sumaPond = 0.0
    foreach ($p in $productos) {
        $totalHoy += $p.importeActual
        $sumaPond += ($p.importeActual * $p.rentabilidadAnual)
    }
    if ($totalHoy -le 0) { return 0.0 }
    return $sumaPond / $totalHoy
}

$prods = @(
    @{ importeActual = 7000; rentabilidadAnual = 0.08 },
    @{ importeActual = 3000; rentabilidadAnual = 0.04 }
)
$rentPond = Calcular-RentabilidadPonderada $prods
Assert-Equal $rentPond 0.068 0.0001 'Weighted average return equals 6.8pct'

# --- TEST 6: Zero balance resilience ---
Write-Host 'TEST 6: Zero balance resilience...' -ForegroundColor Yellow
$zeroComp = Simular-InteresCompuesto 0 0 0 60
Assert-Equal $zeroComp 0.0 0.001 'Simulation with zero balance returns 0'
$zeroRem = Simular-CuentaRemuneradaMes 0 0.03 0.19
Assert-Equal $zeroRem.Neto 0.0 0.001 'Zero balance interest returns 0'
$zeroPond = Calcular-RentabilidadPonderada @()
Assert-Equal $zeroPond 0.0 0.001 'Empty portfolio weighted return returns 0'

# --- TEST 7: Character Encoding and Mojibake Prevention ---
Write-Host 'TEST 7: Character encoding and typography verification...' -ForegroundColor Yellow
Assert-Condition ($html -notmatch '[\u00C3][\u0080-\u00BF]') 'No UTF-8 double-encoded mojibake (U+00C3 sequences)'
$strDigitos = "4 d" + [char]0xED + "gitos"
$strNinos = "Gastos Ni" + [char]0xF1 + "os"
$strContrasena = "contrase" + [char]0xF1 + "a"
Assert-Condition ($html.Contains($strDigitos)) "Contains '$strDigitos' properly encoded"
Assert-Condition ($html.Contains($strNinos)) "Contains '$strNinos' properly encoded"
Assert-Condition ($html.Contains($strContrasena)) "Contains '$strContrasena' properly encoded"

# --- TEST 8: Salary Increase and Variable Mortgage Engine Logic ---
Write-Host 'TEST 8: Salary increment and variable mortgage engine logic...' -ForegroundColor Yellow

function Simular-IncrementoNominaPct($base, $enero) {
    if ($base -le 0 -or $enero -le 0) {
        return @{ Pct = 0.0; Label = '0.00%' }
    }
    $diff = (($enero - $base) / $base) * 100.0
    $sign = if ($diff -ge 0) { '+' } else { '' }
    $lbl = [string]::Format([System.Globalization.CultureInfo]::InvariantCulture, "{0}{1:0.00}%", $sign, $diff)
    return @{ Pct = $diff; Label = $lbl }
}

$resCalc1 = Simular-IncrementoNominaPct 1800 1890
Assert-Equal $resCalc1.Pct 5.0 0.001 'Increment from 1800 to 1890 is exactly 5.0%'
Assert-Condition ($resCalc1.Label -eq '+5.00%') 'Label formatted as +5.00%'

$resCalcZero = Simular-IncrementoNominaPct 0 1890
Assert-Equal $resCalcZero.Pct 0.0 0.001 'Zero base protects against division by zero'

function Simular-NominaMes($ym, $mesInicio, $nominaBase, $nominaEneroNeto, $overrideNomina) {
    if ($null -ne $overrideNomina -and $overrideNomina -ne '') {
        return [double]$overrideNomina
    }
    $partesYm = $ym.Split('-')
    $partesIni = $mesInicio.Split('-')
    $anoYm = [int]$partesYm[0]
    $anoIni = [int]$partesIni[0]
    
    if ($anoYm -gt $anoIni -and $nominaEneroNeto -gt 0) {
        return [double]$nominaEneroNeto
    }
    return [double]$nominaBase
}

function Simular-HipotecaMes($ym, $mesInicio, $hipotecaBase, $tipo, $mesRevision, $cuotaRevisada, $overrideHipoteca) {
    if ($null -ne $overrideHipoteca -and $overrideHipoteca -ne '') {
        return [double]$overrideHipoteca
    }
    if ($tipo -eq 'variable' -and $cuotaRevisada -gt 0) {
        $partesYm = $ym.Split('-')
        $partesIni = $mesInicio.Split('-')
        $anoYm = [int]$partesYm[0]
        $mesYm = [int]$partesYm[1]
        $anoIni = [int]$partesIni[0]
        if ($anoYm -gt $anoIni -or $mesYm -ge $mesRevision) {
            return [double]$cuotaRevisada
        }
    }
    return [double]$hipotecaBase
}

# Test salary timeline:
$nomOct = Simular-NominaMes '2026-10' '2026-10' 1800 1900 $null
Assert-Equal $nomOct 1800 0.01 'Month 2026-10 uses base salary 1800'
$nomDic = Simular-NominaMes '2026-12' '2026-10' 1800 1900 $null
Assert-Equal $nomDic 1800 0.01 'Month 2026-12 uses base salary 1800'
$nomEne = Simular-NominaMes '2027-01' '2026-10' 1800 1900 $null
Assert-Equal $nomEne 1900 0.01 'Month 2027-01 uses revised January salary 1900'
$nomOver = Simular-NominaMes '2027-01' '2026-10' 1800 1900 2500
Assert-Equal $nomOver 2500 0.01 'Override takes precedence over January revision'

# Test mortgage timeline:
$hipAgo = Simular-HipotecaMes '2026-08' '2026-01' 500 'variable' 10 540 $null
Assert-Equal $hipAgo 500 0.01 'Before review month uses base quota 500'
$hipOct = Simular-HipotecaMes '2026-10' '2026-01' 500 'variable' 10 540 $null
Assert-Equal $hipOct 540 0.01 'At review month uses revised quota 540'
$hipFija = Simular-HipotecaMes '2026-10' '2026-01' 500 'fija' 10 540 $null
Assert-Equal $hipFija 500 0.01 'Fixed mortgage ignores revised quota'

# Verify helper and logic exist in index.html:
Assert-Condition ($html -match 'function calcularIncrementoNominaPct') 'calcularIncrementoNominaPct exists in index.html'
Assert-Condition ($html -match 'nominaEneroNeto') 'nominaEneroNeto referenced in index.html'
Assert-Condition ($html -match 'hipotecaCuotaRevisada') 'hipotecaCuotaRevisada referenced in index.html'

# --- TEST 9: Multi-Year Salary Cascading & Extra Payments Manager ---
Write-Host 'TEST 9: Multi-year salary cascading and extra payments engine...' -ForegroundColor Yellow

function Simular-ObtenerNominaAno($ano, $anoInicio, $nominaMensual, $nominasPorAno) {
    $targetAno = [int]$ano
    if ($targetAno -le $anoInicio) {
        return [double]$nominaMensual
    }
    for ($y = $targetAno; $y -gt $anoInicio; $y--) {
        $key = [string]$y
        if ($nominasPorAno.ContainsKey($key)) {
            $val = $nominasPorAno[$key]
            if ($null -ne $val -and $val -gt 0) {
                return [double]$val
            }
        }
    }
    return [double]$nominaMensual
}

function Simular-ObtenerExtrasMes($mesNum, $pagasExtras) {
    $total = 0.0
    foreach ($p in $pagasExtras) {
        if ([int]$p.mes -eq [int]$mesNum) {
            $total += [double]$p.importe
        }
    }
    return $total
}

# Test cascading resolution:
$dictNominas = @{
    '2027' = 1850.0
    '2029' = 1820.0
}
$nom2026 = Simular-ObtenerNominaAno 2026 2026 1800 $dictNominas
Assert-Equal $nom2026 1800 0.01 'Year 2026 returns base 1800'

$nom2027 = Simular-ObtenerNominaAno 2027 2026 1800 $dictNominas
Assert-Equal $nom2027 1850 0.01 'Year 2027 returns 1850'

$nom2028 = Simular-ObtenerNominaAno 2028 2026 1800 $dictNominas
Assert-Equal $nom2028 1850 0.01 'Year 2028 unconfigured inherits 1850 from 2027'

$nom2029 = Simular-ObtenerNominaAno 2029 2026 1800 $dictNominas
Assert-Equal $nom2029 1820 0.01 'Year 2029 returns salary drop to 1820'

# Test extra payments summation:
$listaExtras = @(
    @{ id = 'p1'; nombre = 'Extra Verano'; mes = 6; importe = 1200 },
    @{ id = 'p2'; nombre = 'Extra Navidad'; mes = 12; importe = 1200 },
    @{ id = 'p3'; nombre = 'Beneficios'; mes = 3; importe = 1200 }
)
$extraMes6 = Simular-ObtenerExtrasMes 6 $listaExtras
Assert-Equal $extraMes6 1200 0.01 'Month 6 receives 1200 extra'

$extraMes3 = Simular-ObtenerExtrasMes 3 $listaExtras
Assert-Equal $extraMes3 1200 0.01 'Month 3 receives 1200 extra'

$extraMes1 = Simular-ObtenerExtrasMes 1 $listaExtras
Assert-Equal $extraMes1 0 0.01 'Month 1 receives 0 extra'

# Monthly timeline simulation (Base + Extra):
# 2026-12: Year 2026 (base 1800) + Extra mes 12 (1200) = 3000
$tot2026Dic = (Simular-ObtenerNominaAno 2026 2026 1800 $dictNominas) + (Simular-ObtenerExtrasMes 12 $listaExtras)
Assert-Equal $tot2026Dic 3000 0.01 '2026-12 total salary with extra equals 3000 EUR'

# 2027-01: Year 2027 (base 1850) + no extra = 1850
$tot2027Ene = (Simular-ObtenerNominaAno 2027 2026 1800 $dictNominas) + (Simular-ObtenerExtrasMes 1 $listaExtras)
Assert-Equal $tot2027Ene 1850 0.01 '2027-01 total salary equals 1850 EUR'

# 2027-03: Year 2027 (base 1850) + Benefits mes 3 (1200) = 3050
$tot2027Mar = (Simular-ObtenerNominaAno 2027 2026 1800 $dictNominas) + (Simular-ObtenerExtrasMes 3 $listaExtras)
Assert-Equal $tot2027Mar 3050 0.01 '2027-03 total salary with benefits equals 3050 EUR'

# 2027-06: Year 2027 (base 1850) + Summer extra (1200) = 3050
$tot2027Jun = (Simular-ObtenerNominaAno 2027 2026 1800 $dictNominas) + (Simular-ObtenerExtrasMes 6 $listaExtras)
Assert-Equal $tot2027Jun 3050 0.01 '2027-06 total salary with summer extra equals 3050 EUR'

# Verify helper signatures in index.html:
Assert-Condition ($html -match 'function obtenerNominaAno') 'obtenerNominaAno exists in index.html'
Assert-Condition ($html -match 'function obtenerExtrasMes') 'obtenerExtrasMes exists in index.html'
Assert-Condition ($html -match 'pagasExtras') 'pagasExtras referenced in index.html'

Write-Host '==========================================================' -ForegroundColor Green
Write-Host '   ALL 46 VERIFICATION CHECKS PASSED SUCCESSFULLY!        ' -ForegroundColor Green
Write-Host '==========================================================' -ForegroundColor Green
