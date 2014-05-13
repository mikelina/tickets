<style scoped>


</style>

<div style="width:640px">
{foreach from=$objects item=obj}
	{if $obj.days > 0}		
		<div class="flowticket" style="background-color:pink; width:{$obj.days*10}px">
			ciao / {$obj.days}
		</div>
	{/if}
{/foreach}		
</div>

{dump var=$objects}