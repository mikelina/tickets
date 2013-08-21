{*
** view template
*}
{assign_associative var="params" inline="false"}
{$html->css("ui.datepicker", null, $params)}
{$javascript->link("jquery/jquery.form", false)}
{$javascript->link("jquery/jquery.selectboxes.pack", false)}
{$javascript->link("jquery/ui/jquery.ui.sortable", true)}
{$javascript->link("jquery/ui/jquery.ui.datepicker", false)}
{if $currLang != "eng"}
{$javascript->link("jquery/ui/i18n/ui.datepicker-$currLang.js", false)}
{/if}

{literal}
<script type="text/javascript">
    $(document).ready(function(){	
		openAtStart("#title,#properties");
    });
</script>
{/literal}

{$view->element("form_common_js")}

{$view->element("modulesmenu")}

{assign_associative var="params" method="view"}
{$view->element("menuleft", $params)}

<div class="head">
	
	<h1>{if !empty($object)}{$object.title|default:"<i>[no title]</i>"}{else}<i>[{t}New item{/t}]</i>{/if}</h1>

</div>

{assign var=objIndex value=0}

{assign_associative var="params" method="view" fixed=true object=$object|default:''}
{$view->element("menucommands", $params)}

<div class="main">	
	
	{$view->element("form")}
		
</div>

{$view->element("menuright")}
