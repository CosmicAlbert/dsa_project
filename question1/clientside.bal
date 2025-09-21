import ballerina/http;
import ballerina/io;
import ballerina/time;

// -------------------- TYPES --------------------
type Assets record {|
    string AssetTag;
    string name;
    string faculty;
    string department;
    string status;
    time:Date acquiredDate;
    map<component> components;
    map<maintainance_schedule> maintainanceSchedules;
    map<workorder> workOrders;
|};

type component record {|
    string id?;
    string Name;
    string description;
    string serialNumber;
|};

type maintainance_schedule record {|
    string id?;
    string status;
    string scheduleType;
    time:Date nextDueDate;
    string description;
|};

type workorder record {|
    string id?;
    string status;
    string description;
    string title;
    string workorderstatus;
    time:Utc openedDate?;
    time:Utc completedDate?;
    map<task> tasks;
|};

type task record {|
    string id?;
    string description;
    string status;
    time:Utc openedDate?;
    time:Utc completedDate?;
|};


final http:Client equipClient = check new ("http://localhost:8080/equipserve");


function getAssets() returns Assets[]|error {
    json resp = check equipClient->get("/assets");
    return <Assets[]>resp;
}

function getAssetByTag(string tag) returns Assets|error {
    return check equipClient->get("/assets/" + tag);
}

function addAsset(Assets newAsset) returns string|error {
    return check equipClient->post("/assets", newAsset);
}

function updateAsset(string tag, Assets updatedAsset) returns string|error {
    return check equipClient->put("/assets/" + tag, updatedAsset);
}

function deleteAsset(string tag) returns string|error {
    return check equipClient->delete("/assets/" + tag);
}

function getAssetsByFaculty(string faculty) returns Assets[]|error {
    return check equipClient->get("/faculty?faculty=" + faculty);
}


function addComponent(string assetTag, component comp) returns component|error {
    return check equipClient->post("/" + assetTag + "/components", comp);
}

function deleteComponent(string assetTag, string compId) returns string|error {
    return check equipClient->delete("/" + assetTag + "/components/" + compId);
}


function addSchedule(string assetTag, maintainance_schedule sched)
        returns maintainance_schedule|error {
    return check equipClient->post("/" + assetTag + "/maintainanceSchedules", sched);
}

function deleteSchedule(string assetTag, string schedId) returns string|error {
    return check equipClient->delete("/" + assetTag + "/maintainanceSchedules/" + schedId);
}

function getOverdueSchedules() returns maintainance_schedule[]|error {
    return check equipClient->get("/maintainance_schedule/Overdue");
}


function addWorkOrder(string assetTag, workorder wrk) returns workorder|error {
    return check equipClient->post("/" + assetTag + "/workorders", wrk);
}

function updateWorkOrder(string assetTag, string workOrderId, workorder wrk)
        returns workorder|error {
    return check equipClient->put("/" + assetTag + "/workorders/" + workOrderId, wrk);
}

function deleteWorkOrder(string assetTag, string workOrderId) returns string|error {
    return check equipClient->delete("/" + assetTag + "/workorders/" + workOrderId);
}


function addTask(string assetTag, string workOrderId, task tsk) returns task|error {
    return check equipClient->post("/" + assetTag + "/workorders/" + workOrderId + "/tasks", tsk);
}


public function main() returns error? {
    io:println("=== Client Demo ===");

    
    Assets newAsset = {
        AssetTag: "",
        name: "3D Printer",
        faculty: "Engineering",
        department: "Mechanical",
        status: "ACTIVE",
        acquiredDate: { year: 2025, month: 9, day: 21 },
        components: {},
        maintainanceSchedules: {},
        workOrders: {}
    };
    string addResp = check addAsset(newAsset);
    io:println("Add Asset -> ", addResp);


    Assets[] assets = check getAssets();
    io:println("All Assets: ", assets);

    
    if assets.length() > 0 {
        string tag = assets[0].AssetTag;
        component comp = { Name: "Motor", description: "Stepper Motor", serialNumber: "M12345" };
        component added = check addComponent(tag, comp);
        io:println("Added Component: ", added);
    }

   
    maintainance_schedule[] overdue = check getOverdueSchedules();
    io:println("Overdue Schedules: ", overdue);
}
