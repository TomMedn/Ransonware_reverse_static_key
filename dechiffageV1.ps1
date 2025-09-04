# Clé et IV en hexadécimal (à remplacer si nécessaire)
$hexKey = "x"
$hexIV  = "x"

function HexStringToByteArray($hexString) {
    -join ($hexString -split '(..)' | Where-Object { $_ } | ForEach-Object { [byte]("0x$_") })
}

$keyBytes = HexStringToByteArray $hexKey
$ivBytes  = HexStringToByteArray $hexIV

# Répertoire courant
$workingDir = Get-Location

# Lister les fichiers *.crypt
$encryptedFiles = Get-ChildItem -Path $workingDir -Filter *.crypt

foreach ($encFile in $encryptedFiles) {
    Write-Host "`nDéchiffrement de : $($encFile.Name)"

    # Lire le contenu chiffré
    $cipherBytes = [System.IO.File]::ReadAllBytes($encFile.FullName)

    # Créer l’objet AES
    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.Key = $keyBytes
    $aes.IV  = $ivBytes
    $aes.Padding = "PKCS7"
    $aes.Mode = "CBC"

    $decryptor = $aes.CreateDecryptor()

    # Créer les flux
    $ms = New-Object System.IO.MemoryStream
    $cs = New-Object System.Security.Cryptography.CryptoStream($ms, $decryptor, [System.Security.Cryptography.CryptoStreamMode]::Write)

    $cs.Write($cipherBytes, 0, $cipherBytes.Length)
    $cs.Close()

    # Déterminer le nom de sortie (sans .crypt)
    $outputPath = $encFile.FullName -replace '\.crypt$', ''

    [System.IO.File]::WriteAllBytes($outputPath, $ms.ToArray())
    Write-Host "Fichier déchiffré : $outputPath"

    # Nettoyage
    $ms.Dispose()
    $aes.Dispose()
}
