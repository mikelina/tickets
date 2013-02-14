{*
Left column menu.
*}

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
	
	
	{if !empty($method) && $method != "index" && $method != "categories"}
	<div class="insidecol">
		<input class="bemaincommands" type="button" value=" {t}Save{/t} " name="save" id="saveBEObject" />
		<!-- <input class="bemaincommands" type="button" value=" {t}clone{/t} " name="clone" id="cloneBEObject" /> -->
		<input class="bemaincommands" type="button" value="{t}Delete{/t}" name="delete" id="delBEObject" />
	</div>
	
		{$view->element("prevnext")}
	
	{/if}

	{if !empty($method) && $method != "categories"}
		{$view->element('select_categories')}
	{/if}

</div>

