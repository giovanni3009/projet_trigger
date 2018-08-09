<?php
	include("menu.php");
?>
<div class="container">
<div>
<button type="button" class="btn btn-primary btn-md" data-toggle="modal" data-target="#myModal"><i class="glyphicon glyphicon-plus"></i> Ajouter une Recette</button>
</div>
<br/>
<div class="well">
	<center> <b> <h4>Liste des recettes ajoutées</h4> </b> </center>
</div>

	<table id="table" class="table table-striped table-bordered table-hover" id="table">
	  <thead class="thead-light">
	    <tr>
	      <th scope="col">#</th>
	      <th scope="col">Montant</th>
	      <th scope="col">Date Ajout</th>
	      <th scope="col">Date Modification</th>
	      <th scope="col">Utilisateur</th>
          <th style="width:150px;">Action</th>
	    </tr>
	  </thead>
	  <tbody>
	    <tr>
	      <th scope="row">3</th>
	      <td>Larry</td>
	      <td>the Bird</td>
	      <td>@twitter</td>
	      <td>@facebook</td>
	      <td><a href="#" class="btn btn-success btn-sm" >Editer</a><a href="" class="btn btn-danger btn-sm" data-toggle="confirmation" data-title="Supprimez??">Supprimer</a> </td>
	    </tr>
	  </tbody>
	</table>
</div>

<div id="myModal" class="modal fade" role="dialog">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">&times;</button>
                <h4 class="modal-title">Ajout Recette</h4>
            </div>
            <div class="modal-body">
                <form action="{{ url_for('ajout') }}" method="POST">
                    <div class="form-group">
                        <label>Recette :</label>
                        <input type="text" class="form-control" name="titre">
                    </div>
                    <div class="form-group">
                <button class="btn btn-primary" type="submit">Ajouter</button>
                <button type="button" class="btn btn-danger" data-dismiss="modal">Annuler</button>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
            </div>
        </div>
    </div>
</div>

    <script type="text/javascript" src="assets/jquery/jquery-2.1.4.min.js"></script>
    <script type="text/javascript" src="assets/datatables/js/dataTables.bootstrap.js"></script>
    <script type="text/javascript" src="assets/datatables/js/jquery.dataTables.min.js"></script>
    <script type="text/javascript" src="assets/bootstrap/js/bootstrap.min.js"></script>
    
<script>
$('#table').dataTable();

$('[data-toggle=confirmation]').confirmation({
  rootSelector: '[data-toggle=confirmation]',
  // other options
});
</script>

