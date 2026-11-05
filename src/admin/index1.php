<!doctype html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <meta name="robots" content="noindex, nofollow" />
    <link href="https://fonts.googleapis.com/css2?family=Montserrat&display=swap" rel="stylesheet">
    <title>Document</title>
    <style>
        body{
            width: 100vw;
            height: 100vh;
            overflow: hidden;
            display: flex;
            justify-content: center;
            align-items: center;
            text-align: center;
            font-family: 'Montserrat', sans-serif;
            padding: 0;
            margin: 0;
        }

        img{
            width: 150px;
        }

        .red{
            color: red;
        }
    </style>
</head>
<?php
$date = '11.12.2020';  //Дата удаления сайта
$current = time();
$block = strtotime($date) - $current;
$bloc_date = floor($block/(60*60*24));
?>

<body>
<div>
    <img src="index.svg" alt="index">
    <h2>Ваш сайт тимчасово заблоковано за несплату</h2>
    <p>Для розблокування сайту зв'яжіться з нами за нашими контактними даними, зробіть запит на рахунок у менеджера, та сплатіть його.
        <br>
        <br>
        <b>Наші контакти:</b><br>
        <a href="tel:+38 (044) 333 4234">+38 (044) 333 4234</a><br>
        <a href="tel:+38 (067) 534 3644">+38 (067) 534 3644</a><br>
        <a href="tel:+38 (050) 369 3644">+38 (050) 369 3644</a><br>
        <a href="fillsites.net">fillsites.net</a>
        <p class="red">Якщо за оренду сайту не буде сплачено впродовж <?php echo $bloc_date; ?> календарних днів, він буде видалений назавжди!</p>
    </p>
</div>
</body>
</html>