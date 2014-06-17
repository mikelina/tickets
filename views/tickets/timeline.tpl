{if strnatcmp($conf->majorVersion, '3.3') > 0}
    {$html->script('libs/jquery/jquery-migrate-1.2.1', false)} {* assure js retrocompatibility *}
{/if}

{literal}
<script type="text/javascript">
    $(document).ready(function(){	
    	openAtStart("#ticketfilter");
    });
</script>
{/literal}

{$view->element("modulesmenu")}

{assign_associative var="params" method="timeline"}

{$view->element("menuleft", $params)}

{$view->element("menucommands", $params)}

{$view->element("toolbar")}

<div class="mainfull" style="right:0px">
	<form method="post" action="" id="formObject">

	<div style="width:680px">{$view->element("filters")}</div>
	
	{$view->element("timeline")}

	</form>
</div>