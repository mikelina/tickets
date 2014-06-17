{assign_associative var="params" inline="false"}
{$html->css("ui.datepicker", null, $params)}

{if strnatcmp($conf->majorVersion, '3.3') > 0}
    {$html->script('libs/jquery/jquery-migrate-1.2.1', false)} {* assure js retrocompatibility *}
{/if}

{$html->script('libs/jquery/ui/jquery.ui.datepicker.min', false)}
{if $currLang != "eng"}
    {$html->script("libs/jquery/ui/i18n/jquery.ui.datepicker-$currLang2.min.js", false)}
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

<div class="mainfull">
	<form method="post" action="" id="formObject">

	{$view->element("filters")}
	
	{$view->element("timeline")}

	</form>
</div>