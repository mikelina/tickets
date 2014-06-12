{*
Left column menu.
*}

{$coeff=$html->params.named.coeff|default:$html->params.url.coeff|default:20}
{$view->set("method", $method)}
<div class="secondacolonna {if !empty($fixed)}fixed{/if}">
	
	{if !empty($method) && $method != "index" && $method != "categories"}
		{assign var="back" value=$session->read("backFromView")}
	{else}
		{assign_concat var="back" 1=$html->url('/') 2=$currentModule.url}
	{/if}

	<div class="modules">
		<label class="{$moduleName}" rel="{$back}">{t}{$currentModule.label}{/t}</label>
	</div> 

	{if !empty($method) && $method == "timeline"}

		<form id="calendar_from" style="padding:10px" name="calendar_from" method="get">
			<label>{t}start from{/t}:</label> 
			<fieldset style="line-height:2.5em; margin:10px 0 10px 0;  padding-bottom:0px; display:block">
				{$time=$prevmonday|date_format:'%s'}
				{html_select_date field_order="DMY" field_separator="<br />" time=$time start_year="-3" end_year="+1" display_days=true}
			</fieldset>
			<input type="submit" style="width:100%" value="{t}go{/t}">
		</form>

		<div class="insidecol">
			<a title="{$prevWeekMonday|date_format:'%x'}" href="{$html->url('/')}tickets/timeline?{$time|date_format:'Date_Day=%d&Date_Month=%m&Date_Year=%Y'}&coeff={$coeff}">{t}prev week{/t}</a>
			<hr />
			<a title="{$nextWeekMonday|date_format:'%x'}" href="{$html->url('/')}tickets/timeline?{$nextWeekMonday|date_format:'Date_Day=%d&Date_Month=%m&Date_Year=%Y'}&coeff={$coeff}">{t}next week{/t}</a>
		</div>

		<ul style="margin:20px" class="insidecol">
			<li>
				<a href="{$html->here}?{foreach from=$html->params.url item=item key=key}{if $key!='url' && $key!='coeff'}{$key}={$item}&{/if}{/foreach}coeff=10">10</a>
			</li>
			<li>
				<a href="{$html->here}?{foreach from=$html->params.url item=item key=key}{if $key!='url' && $key!='coeff'}{$key}={$item}&{/if}{/foreach}coeff=20">20</a>
			</li>
			<li>
				<a href="{$html->here}?{foreach from=$html->params.url item=item key=key}{if $key!='url' && $key!='coeff'}{$key}={$item}&{/if}{/foreach}coeff=50">50</a>
			</li>
		</ul>

	{elseif !empty($method) && $method != "index" && $method != "categories"}

	<div class="insidecol">
		<input class="bemaincommands" type="button" value=" {t}Save{/t} " name="save" id="saveBEObject" />
		<!-- <input class="bemaincommands" type="button" value=" {t}clone{/t} " name="clone" id="cloneBEObject" /> -->
		{if !empty($object)}
			{if $object.ticket_status == "new" && empty($object.EditorNote)}
				<input class="bemaincommands" type="button" value="{t}Delete{/t}" name="delete" id="delBEObject" />
			{/if}
			<input class="bemaincommands modalbutton" rel="{$html->url('/tickets/closeAs')}" title="{t}Close ticket as{/t}" type="button" value="{t}Close{/t}" name="close" id="closeDialogButton"{if $conf->ticketStatus[$object.ticket_status] == "off"} disabled{/if} />
		{/if}
	</div>
	
		{$view->element("prevnext")}

	{/if}

	{if strcmp($conf->majorVersion, "3.3") < 0}
		{if !empty($method) && $method != "categories"}
			{$view->element('select_categories')}
		{/if}
	{/if}
</div>

