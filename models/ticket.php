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
 * Tickets ticket object
 *
 */
class Ticket extends BEAppObjectModel {

	public $searchFields = array("title" => 8 , "description" => 4,
		"ticket_status" => 6, "severity" => 6);

	public $objectTypesGroups = array("related");

	public $actsAs = array(
		'CompactResult' 		=> array("ReferenceObject"),
		'SearchTextSave',
		'ForeignDependenceSave' => array('BEObject'),
		'DeleteObject' 			=> 'objects',
		'TicketNotifier'
	);

	protected $modelBindings = array(
			"detailed" =>  array("BEObject" => array("ObjectType",
														"UserCreated",
														"UserModified",
														"ObjectProperty",
														"RelatedObject",
														"Annotation",
														"Category",
														"User",
														"Version" => array("User.realname", "User.userid")
														)),
			"default" => array("BEObject" => array("ObjectProperty",
								"ObjectType", "Annotation",
								"Category", "RelatedObject","User" )),

			"minimum" => array("BEObject" => array("ObjectType"))
	);

	function beforeValidate() {
        $this->checkDate('exp_resolution_date');
	}

	function beforeSave() {
		if("off" === $this->data["Ticket"]["status"] && empty($this->data["Ticket"]["closed_date"]) ) {
			$this->data["Ticket"]["closed_date"] = date("Y-m-d H:i:s");
		} else if(!empty($this->data["Ticket"]["closed_date"])){
			$this->data["Ticket"]["closed_date"] = null;
		}
		return true ;
	}
	
	/**
	 * Create a ticket note from SCM integration
	 * @param unknown $data
	 */
	public function saveScmData($data) {
	    
	    $sys = Configure::read("scmIntegration.system");
	    if ($sys === "git") {
	        $this->saveGitData($data);
	    } elseif ($sys === "svn") {
	        $this->saveSvnData($data);
	    }
	}

	private function saveSvnData($commitData) {
	    $this->saveCommitData($commitData);
	}
	
	private function saveGitData($commitData) {
	    $lines = explode("###", $commitData);
	    foreach ($lines as $l) {
	        if (!empty($l)) {
	            $this->saveCommitData($commitData);
	        }
	    }
	}
	
    private function saveCommitData($ciData) {
        $userModel = ClassRegistry::init("User");
        $editorNoteModel = ClassRegistry::init("EditorNote");
        
        $items = explode("|", $ciData);
        $user = $items[0];
        $beditaUser = Configure::read("scmIntegration.users." . $user);
        if (!empty($beditaUser)) {
            $userId = $userModel->field("id", array("userid" => $beditaUser));
            $commit = $items[1];
            $commitUrl = Configure::read("scmIntegration.commitBaseUrl") . $commit;
            $msg = $items[2];
            $matches = array();
            preg_match_all("/\s+\#([0-9]+)/i", $msg, $matches);
            $ticketIds = $matches[1];
            if (!empty($ticketIds)) {
                foreach ($ticketIds as $objectId) {
                    $data = array(
                            "object_id" => $objectId,
                            "description" => 'Commit: "' . $msg .
                            '"<br/><a href="' . $commitUrl . '" target="_blank" >' . $commitUrl . "</a>",
                            "author" => "scmIntegration",
                            "user_created" => $userId,
                            "user_modified" => $userId,
                    );
                    $editorNoteModel->create();
                    if (!$editorNoteModel->save($data)) {
                        throw new BeditaException(__("Error saving ticket note", true),
                                $editorNoteModel->validationErrors);
                    }
                    $this->log("Note saved: " . print_r($data, true), LOG_DEBUG);
                }
            }
        }
        $this->log("Commit data: " . $ciData, LOG_DEBUG);
    }

}
?>
