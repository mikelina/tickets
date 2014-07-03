{* timeline works only for BEdita >= 3.4.0 *}

{assign_associative var="params" inline="false"}
{$html->css("ui.datepicker", null, $params)}

{if strnatcmp($conf->majorVersion, '3.4.0') >= 0}
    {$html->script('libs/jquery/jquery-migrate-1.2.1', false)} {* assure js retrocompatibility *}
    {$html->script('libs/jquery/plugins/jquery.form', false)}
    {$html->script('libs/jquery/ui/jquery.ui.datepicker.min', false)}
    {if $currLang != "eng"}
        {$html->script("libs/jquery/ui/i18n/jquery.ui.datepicker-$currLang2.min.js", false)}
    {/if}

    <script type="text/javascript">
        $(document).ready(function(){	
        	openAtStart("#ticketfilter");
        });
    </script>

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

        <div class="tab">
            <h2>Import from JSON</h2>
        </div>
        <form method="post" name="importjson" action="{$html->url('/tickets/importTimelineJSON')}">
            <textarea name="json" style="width: 100%"></textarea>
            <input type="submit" value="load" />
        </form>
    </div>

{/if}