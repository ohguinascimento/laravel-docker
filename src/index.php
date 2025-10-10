<!-- index.php -->

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Meu Servidor PHP com Docker</title>
    <style>
        body { font-family: sans-serif; background-color: #f0f2f5; color: #333; text-align: center; margin-top: 50px; }
        h1 { color: #4a4a4a; }
        .info { background-color: #fff; border: 1px solid #ddd; padding: 20px; display: inline-block; border-radius: 8px; }
    </style>
</head>
<body>
    <div class="info">
        <h1>Olá, Mundo! 🐘</h1>
        <p>Seu servidor PHP está funcionando corretamente dentro de um contêiner Docker.</p>
        <p>Versão do PHP: <?php echo phpversion(); ?></p>
    </div>
</body>
</html>
