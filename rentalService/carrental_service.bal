import ballerina/grpc;


map<User> users = {};
map<Car> cars = {}; 
map<CartItem> carts = {};
map<Reservation> reservations = {};



listener grpc:Listener ep = new (9090);

@grpc:Descriptor {value: RENTAL_DESC}
service "CarRental" on ep {

    remote function AddCar(AddCarRequest value) returns AddCarResponse|error {
    }

    remote function CreateUsers(CreateUsersRequest value) returns CreateUsersResponse|error {
    }

    remote function UpdateCar(UpdateCarRequest value) returns UpdateCarResponse|error {
    }

remote function RemoveCar(RemoveCarRequest value) returns RemoveCarResponse|error {
}


remote function SearchCar(SearchCarRequest value) returns SearchCarResponse|error {
}


    remote function AddToCart(AddToCartRequest value) returns AddToCartResponse|error {
    }

    remote function PlaceReservation(PlaceReservationRequest value) returns PlaceReservationResponse|error {
    }

    remote function ListAvailableCars(ListAvailableCarsRequest value) returns stream<Car, error?>|error {
    }
}
