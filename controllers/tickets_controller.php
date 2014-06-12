<?php
/*-----8<--------------------------------------------------------------------
 *
 * BEdita - a semantic content management framework
 *
 * Copyright 2013 ChannelWeb Srl, Chialab Srl
 *
 * This file is part of BEdita: you can redistribute it and/or modify
 * it under the terms of the Affero GNU General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * BEdita is distributed WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the Affero GNU General Public License for more details.
 * You should have received a copy of the Affero GNU General Public License
 * version 3 along with BEdita (see LICENSE.AGPL).
 * If not, see <http://gnu.org/licenses/agpl-3.0.html>.
 *
 *------------------------------------------------------------------->8-----
 */

/**
 * tickets controller class
 *
 *
 */
class TicketsController extends ModulesController {

	public $uses = array('Ticket', 'User', 'Group','Category') ;
	var $helpers 	= array('BeTree', 'BeToolbar');

	protected $moduleName = 'tickets';

	protected function beditaBeforeFilter() {
		BeLib::getObject('BeConfigure')->loadPluginLocalConfig($this->moduleName);
	}

	public function index($id = null, $order = "", $dir = true, $page = 1, $dim = 20) {
		$conf  = Configure::getInstance() ;
		$filter["object_type_id"] = array($conf->objectTypes['ticket']["id"]);
		$filter["user_created"] = "";
		$filter["Ticket.severity"] =  (!empty($this->data['severity'])) ? $this->data['severity'] : "";
		if(!empty($this->data['status'])) {
			$filter["Ticket.ticket_status"] = array_keys($this->data['status']);
		} else {
			$ticketStatus = array_intersect($conf->ticketStatus, array("draft", "on"));
			$filter["Ticket.ticket_status"] = array_keys($ticketStatus);
		}
		if(empty($this->data) || !empty($this->data['hide_status_off'])) {
			$filter["status"] = "<> 'off'";
		}

		if (!empty($this->data['assigned_to'])) {
			$filter["ObjectUser.switch"] = "assigned";
			$filter["ObjectUser.user_id"] = $this->data['assigned_to'];
		}

		$filter["exp_resolution_date"] = "";
		$filter["BEObject.user_created"] = (!empty($this->data['reporter'])) ? $this->data['reporter'] : "";
		$filter["count_annotation"] = array("EditorNote");
		$f = $filter;
		$this->paginatedList($id, $filter, $order, $dir, $page, $dim);
		$this->loadCategories($filter["object_type_id"]);
		$this->loadReporters();
		$this->loadAssignedUsers();
		if(!empty($this->data['status'])) {
			$f["f_status"] = $this->data['status'];
		}
		if(!empty($this->data['reporter'])) {
			$f["f_reporter"] = $this->data['reporter'];
		}
		if(!empty($this->data['severity'])) {
			$f["f_severity"] = $this->data['severity'];
		}
		if(empty($this->data) || !empty($this->data['hide_status_off'])) {
			$f["hide_status_off"] = "true";
		}
		if (!empty($this->data['assigned_to'])) {
			$f["f_assigned_to"] = $this->data['assigned_to'];
		}
		$this->set("filter",$f);
	}


	/**
	 * view all tickets in a timeline view
	 */

	public function timeline () {
    	$conf  = Configure::getInstance() ;
		
		$tickets = array();

        if(!empty($this->params["url"]["Date_Day"])) {
            $startDay = $this->params["url"]["Date_Year"] . "-" . 
                $this->params["url"]["Date_Month"] . "-" . 
                str_pad($this->params["url"]["Date_Day"], 2, "0", STR_PAD_LEFT);
        } else {
            $startDay = date("Y-m-d");
        }
		$startTime = $startDay . " 00:00:00";
		$this->set("startTime", $startTime);

		$timeline_start = strtotime($startDay);
		$objects = array();
		$name = "tickets";
/*
		$query = 	"SELECT tickets.*, areas.public_name as publication_name, trees.area_id, object_relations.*".
					"FROM tickets ".
					"INNER join objects on objects.id = tickets.id ".
					"LEFT JOIN trees ON tickets.id = trees.id ".
					"LEFT JOIN areas ON areas.id = area_id ".
					"INNER JOIN object_relations ON object_relations.id = tickets.id ".
					"AND object_relations.switch = 'subtask' ".
					"GROUP BY tickets.id ".
					"ORDER BY publication_name desc";
	    $tickets = $this->Ticket->query($query);
*/


        $tickets = $this->Ticket->find("all", array(
                "conditions" => array(
                // TODO
                //solo tickets senza relazione 'subtask_of'
                //exp_resolution_date oppure closed_date suoi o di tutti i suoi subtickets, maggiore o uguale ad una settimana prima della data passata (default oggi)
                //raggruppati per pubblicazione
                //coi filtri passati
        		)
        ));


		//day from first monday before ...
		$prevmonday = strtotime('last monday',$timeline_start);
        $mondayshift = floor(($timeline_start-$prevmonday)/86400);

        //where is today?
        $today = strtotime('today'); 
       	$todayshift = floor(($today-$prevmonday)/86400);

		foreach ($tickets as &$obj) {
			//per ogni tiket prende i dettagli dei subtask (...)
			foreach ($obj['RelatedObject'] as $r) {
				if($r['switch'] == 'subtask') {	
					$delay = '';
					
					$detail = $this->Ticket->find('first', array(
					    'conditions' => array('Ticket.id' => $r['object_id'])
					));
					//duration in days of the ticket
					if (!empty($detail["start_date"])) {

						$start_date = strtotime($detail["start_date"]);
						$exp_resolution_date = strtotime($detail["exp_resolution_date"]);

						if (!empty($detail["closed_date"])) {
							$closed_date = strtotime($detail["closed_date"]);
						} 

						$interval = $exp_resolution_date-$start_date; 

						//counting delay
						if (!empty($exp_resolution_date)) {
							if (empty($detail["closed_date"])) {
								if($today > $exp_resolution_date) {
									$delay = $today-$exp_resolution_date;
								}
							} else {
								$delay = $closed_date-$exp_resolution_date;
							}
						}
						if(!empty($delay)) {
							$detail["delay"] = floor($delay/86400); //delay in days
						}

						$shift = floor(($start_date-$timeline_start)/86400);

						$detail["days"] = floor($interval/86400); //width in days of the ticket
						$detail["shift"] = $shift+$mondayshift; //distance from now (or parmas starting date) 
						$obj["subtasks"][] = $detail;
					}
				}
			}
		}

		$this->set("timeline_start", $timeline_start);
		$this->set("mondayshift", $mondayshift);
		$this->set("todayshift", $todayshift);
		$this->set("prevmonday", $prevmonday);
        $this->set("tickets", $tickets);
        //pr($tickets); exit;

	 }



	public function view($id = null) {
		$this->viewObject($this->Ticket, $id);
		if (!empty($id)) {
			$this->viewVars['object']['User'] = Set::combine($this->viewVars['object'], 'User.{n}.id', 'User.{n}', 'User.{n}.ObjectUser.switch');
		}
		$this->set("objectTypeId", Configure::read("objectTypes.ticket.id"));
		$this->filterCommits();
	}

	private function filterCommits() {
	    // filter commits on scmIntegration
	    $scmGroup = Configure::read("scmIntegration.groupVisible");
        if (!empty($scmGroup)) {
            $groups = $this->BeAuth->user["groups"];
	        if (!in_array($scmGroup, $groups)) {
	            $this->set("hideCommits", true);
	        }
        }
	}
	
	public function delete() {
		$this->checkWriteModulePermission();
		$objectsListDeleted = $this->deleteObjects("Ticket");
		$this->userInfoMessage(__("Ticket deleted", true) . " -  " . $objectsListDeleted);
		$this->eventInfo("ticket $objectsListDeleted deleted");
	}

	public function deleteSelected() {
		$this->checkWriteModulePermission();
		$objectsListDeleted = $this->deleteObjects("Ticket");
		$this->userInfoMessage(__("Ticket", true) . " -  " . $objectsListDeleted);
		$this->eventInfo("Ticket $objectsListDeleted deleted");
	}

	public function save() {
		$this->checkWriteModulePermission();
		$this->Transaction->begin();
		$this->saveObject($this->Ticket);
	 	$this->Transaction->commit() ;
 		$this->userInfoMessage(__("Ticket saved", true)." - ".$this->data["title"]);
		$this->eventInfo("ticket [". $this->data["title"]."] saved");
	}

	/**
	 * save editor note
	 * if it fails throw BeditaAjaxException managed like json object
	 */
	public function saveNote() {
		$EditorNote = ClassRegistry::init("EditorNote");
		$EditorNote->Behaviors->detach("Notify");
		$EditorNote->Behaviors->attach("TicketNotifier");
		$this->requestAction(array(
				"controller" => "pages",
				"action" => "saveNote"
			), array("data" => $this->data)
		);
	}

    /**
     * Add notes via scripts/hooks - e.g. svn/git commits for ticket
     */
	public function noteHook() {
        $res = '{"ok": "true"}';
	    $this->BeAuth->logout();
        // do some stuff...
        if (empty($this->params['form']['commit_data'])) {
            $res = '{"ok": "false", "errorMessage" : "missing commit_data"}';
        } else {
            $commitData = $this->params['form']['commit_data'];
            $repo = $this->params['form']['repo'];
            $this->Ticket->saveScmData($commitData, $repo);
        }
        echo $res;
        exit;
	}

	protected function beforeCheckLogin() {
        if ($this->action === "noteHook") {
            if(!empty($this->params['form']['userid']) && 
                !empty($this->params['form']['passwd'])) {
                $userid = $this->params['form']['userid'];
                $password = $this->params['form']['passwd'];
                if(!$this->BeAuth->login($userid, $password)) {
                    $this->eventError("Hook login error");
                    $this->log("Hook login error: " . $userid . ":" . $password);
                }
            }
        }
	}
	
	/**
	 * load an editor note
	 */
	public function loadNote() {
		$this->layout = "ajax";
		$editorNoteModel = ClassRegistry::init("EditorNote");
		$this->set("note", $editorNoteModel->find("first", array(
			"conditions" => array("EditorNote.id" => $this->params["form"]["id"]))
		));
		$this->render('/elements/single_note');
	}

	public function categories() {
		$this->showCategories($this->Ticket);
	}

	public function saveCategories() {
		$this->checkWriteModulePermission();
		if(empty($this->data["label"]))
			throw new BeditaException( __("No data", true));
		$this->Transaction->begin() ;
		if(!ClassRegistry::init("Category")->save($this->data)) {
			throw new BeditaException(__("Error saving tag", true), $this->Category->validationErrors);
		}
		$this->Transaction->commit();
		$this->userInfoMessage(__("Category saved", true)." - ".$this->data["label"]);
		$this->eventInfo("category [" .$this->data["label"] . "] saved");
	}

	public function showUsers($id = null) {

		$groups = Configure::read("ticketAssignGroups");
		if (empty($groups)) {
			$groups = $this->Group->getList(array("backend_auth" => 1));
		}
		$users = $this->User->find("all", array(
				"contain" => array(
					"Group" => array(
						"conditions" => array("name" => $groups)
						)
					)
				)
			);

		$usersList = array();
		$switch = (!empty($this->params["named"]["relation"]))? $this->params["named"]["relation"] : "assigned";
		if (!empty($id)) {
			$objectUserModel = ClassRegistry::init("ObjectUser");
			$usersList = $objectUserModel->find("list", array(
						"conditions" => array("object_id" => $id, "switch" => $switch),
						"fields" => array("ObjectUser.user_id"),
					)
			);
		// for new object set session user as notified
		} elseif ($switch == 'notify') {
			$userSession = $this->BeAuth->getUSerSession();
			$usersList = array($userSession['id']);
		}

		foreach ($users as $k => $u) {
			if (empty($u["Group"])) {
				unset($users[$k]);
			} else {
				if (in_array($u["User"]["id"], $usersList)) {
					$users[$k]["User"]["related"] = true;
				}
			}
		}

		$this->set('users', $users);
		$this->set('relation', $switch);
		$this->layout = null;
	}

	public function deleteCategories() {
		$this->checkWriteModulePermission();
		if(empty($this->data["id"]))
			throw new BeditaException( __("No data", true));
		$this->Transaction->begin() ;
		if(!ClassRegistry::init("Category")->del($this->data["id"])) {
			throw new BeditaException(__("Error saving tag", true), $this->Category->validationErrors);
		}
		$this->Transaction->commit();
		$this->userInfoMessage(__("Category deleted", true) . " -  " . $this->data["label"]);
		$this->eventInfo("Category " . $this->data["id"] . "-" . $this->data["label"] . " deleted");
	}

	public function closeAs() {
		$this->layout = 'ajax';
		$status = Configure::read('ticketStatus');
		$closeStatus = array();
		foreach ($status as $label => $statusValue) {
			if ($statusValue == "off") {
				$closeStatus[] = $label;
			}
		}
		$this->set('closeStatus', $closeStatus);
	}

	/**
	 * load all users with at least one ticket assigned and
	 * load users assigned foreach ticket
	 */
	protected function loadAssignedUsers() {
		$objectUser = ClassRegistry::init("ObjectUser");

		// load all users with a ticket assigned
		$all_users_id = $objectUser->find("list", array(
			"fields" => "user_id",
			"conditions" => array("switch" => "assigned")
		));
		$all_users = array();
		if(!empty($all_users_id)) {
			$all_users = ClassRegistry::init("User")->find("all", array(
				"conditions" => array("User.id" => $all_users_id),
				"recursive" => -1
			));
		}
		$this->set("assignedUsers", $all_users);

		// load specific tickets assignment
		if (!empty($this->viewVars["objects"])) {
			foreach ($this->viewVars["objects"] as &$object) {
				$users_id = $objectUser->find("list", array(
					"fields" => "user_id",
					"conditions" => array(
						"switch" => "assigned",
						"object_id" => $object["id"]
					)
				));

				$users = array();
				if(!empty($users_id)) {
					$users = ClassRegistry::init("User")->find("all", array(
						"conditions" => array("User.id" => $users_id),
						"recursive" => -1
					));
				}

				$object["UsersAssigned"] = Set::classicExtract($users, '{n}.User');
			}
		}
	}

	/**
	 * load all reporters
	 */
	protected function loadReporters() {
		$users_id = ClassRegistry::init("BEObject")->find('list', array(
			'fields' => 'user_created',
			'conditions' => array("object_type_id" => Configure::read('objectTypes.ticket.id'))
		));
		$users_id = array_unique($users_id);
		$reporters = array();
		if(!empty($users_id)) {
			$reporters = ClassRegistry::init("User")->find("all", array(
				"conditions" => array('id' => $users_id),
				'recursive' => -1
			));
		}
		$this->set("reporters",$reporters);
	}

	protected function forward($action, $esito) {
		$REDIRECT = array(
			"cloneObject"	=> 	array(
							"OK"	=> "/tickets/view/".@$this->Ticket->id,
							"ERROR"	=> "/tickets/view/".@$this->Ticket->id
							),
			"view"	=> 	array(
							"ERROR"	=> "/tickets"
							),
			"save"	=> 	array(
							"OK"	=> "/tickets/view/".@$this->Ticket->id,
							"ERROR"	=> $this->referer()
							),
			"saveCategories" 	=> array(
							"OK"	=> "/tickets/categories",
							"ERROR"	=> "/tickets/categories"
							),
			"deleteCategories" 	=> array(
							"OK"	=> "/tickets/categories",
							"ERROR"	=> "/tickets/categories"
							),
			"delete" =>	array(
							"OK"	=> $this->fullBaseUrl . $this->Session->read('backFromView'),
							"ERROR"	=> $this->referer()
							),
			"deleteSelected" =>	array(
							"OK"	=> $this->referer(),
							"ERROR"	=> $this->referer()
							),
			"addItemsToAreaSection"	=> 	array(
							"OK"	=> $this->referer(),
							"ERROR"	=> $this->referer()
							),
			"changeStatusObjects"	=> 	array(
							"OK"	=> $this->referer(),
							"ERROR"	=> $this->referer()
							)
		);
		if(isset($REDIRECT[$action][$esito])) return $REDIRECT[$action][$esito] ;
		return false ;
	}

}
?>