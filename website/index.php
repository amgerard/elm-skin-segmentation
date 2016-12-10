
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
  <meta name="description" content="">
  <meta name="author" content="">

  <title>Skin Detection using ELM</title>

  <!-- Bootstrap core CSS -->
  <link href="css/bootstrap.min.css" rel="stylesheet">

  <!-- IE10 viewport hack for Surface/desktop Windows 8 bug -->
  <link href="css/ie10-viewport-bug-workaround.css" rel="stylesheet">

  <!-- Custom styles for this template -->
  <link href="css/starter-template.css" rel="stylesheet">

  <!-- Just for debugging purposes. Don't actually copy these 2 lines! -->
  <!--[if lt IE 9]><script src="../../assets/js/ie8-responsive-file-warning.js"></script><![endif]-->
  <script src="js/ie-emulation-modes-warning.js"></script>

  <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
      <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
      <![endif]-->
    </head>

    <body>

      <nav class="navbar navbar-inverse navbar-fixed-top">
        <div class="container">
          <div class="navbar-header">
            <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
              <span class="sr-only">Toggle navigation</span>
              <span class="icon-bar"></span>
              <span class="icon-bar"></span>
              <span class="icon-bar"></span>
            </button>
            <a class="navbar-brand" href="#">Skin Detection</a>
          </div>
        </div>
      </nav>

      <div class="container">

        <div class="starter-template">
          <h1>Select an image</h1>

          <form class="form-inline" method="post" enctype="multipart/form-data">
            <div class="form-group">
              <input type="file" name="uploadedfile" class="filestyle" data-buttonText="Select Image">
            </div>
            <button type="submit" class="btn btn-default" name="submit">Upload</button>
          </form>


        </div>

        <?php
        if (isset($_POST['submit'])){
          $target_path = "inputs/";
          $target_path2 = "outputs/";
          $path_info = pathinfo($_FILES['uploadedfile']['name']);
          if (!isset($path_info['extension'])) $path_info['extension'] = "";
          $target_path = $target_path . md5(rand()) . '.' . $path_info['extension']; 
          $target_path2 = $target_path2 . md5(rand()) . '.' . $path_info['extension']; 

          if(in_array($path_info['extension'], array('jpg', 'jpeg', 'png')) && move_uploaded_file($_FILES['uploadedfile']['tmp_name'], $target_path)) {
            exec(sprintf("python get_skin_for_image.py elm.pkl %s %s", $target_path, $target_path2));
            ?>

            <div class="row">
              <div class="col-md-6"><img src="<?= $target_path; ?>" width="100%" /></div>
              <div class="col-md-6"><img src="<?= $target_path2; ?>" width="100%" /></div>
            </div>
            <?php
          } else{
            ?>

            <center><p class="lead">Please select a valid image file.</p></center>
            
            <?php
          }
        }
        ?>




      </div><!-- /.container -->




    <!-- Bootstrap core JavaScript
    ================================================== -->
    <!-- Placed at the end of the document so the pages load faster -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>
    <script>window.jQuery || document.write('<script src="js/jquery.min.js"><\/script>')</script>
    <script src="js/bootstrap.min.js"></script>
    <!-- IE10 viewport hack for Surface/desktop Windows 8 bug -->
    <script src="js/ie10-viewport-bug-workaround.js"></script>
    <script type="text/javascript" src="js/bootstrap-filestyle.min.js"> </script>
  </body>
  </html>
