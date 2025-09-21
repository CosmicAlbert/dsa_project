import ballerina/grpc;


map<User> users = {};
map<Car> cars = {}; 
map<CartItem> carts = {};
map<Reservation> reservations = {};



listener grpc:Listener ep = new (9090);

@grpc:Descriptor {value: RENTAL_DESC}
service "CarRental" on ep {

    remote function AddCar(AddCarRequest value) returns AddCarResponse|error {
        string plate =value.car.plate;
        if cars.hasKey(plate) {
            return error("Car with plate " + plate + " already exists.");
        }
        cars[plate] = value.car;
        return {plate: plate, message: "car has been added"}; 
    }

    remote function CreateUsers(CreateUsersRequest value) returns CreateUsersResponse|error {
        foreach var user in value.users {
            if users.hasKey(user.username) {
                return error("User with the username " + user.username + " already exists.");
            }
            users[user.username] = user; 
        }
        return {message: "Users has been created"};
    }

    remote function UpdateCar(UpdateCarRequest value) returns UpdateCarResponse|error {
        string plate = value.plate;
        if cars.hasKey(plate) {
            cars[plate] = value.updated_car;
        return {message: "car has been updated"};

        } else {
            return error("Car with the plate " + plate + " does not exist.");
        }
        
    }

remote function RemoveCar(RemoveCarRequest value) returns RemoveCarResponse|error {
    string plate = value.plate;
    if cars.hasKey(plate) {
        _ = cars.remove(plate);
        Car[] remainingCars = [];
        foreach string key in cars.keys() {
            Car? car = cars[key];       
            if car is Car {             
                remainingCars.push(car);
            }
        }
        return { cars: remainingCars, message: "The car has been removed" };
    } else {
       
        Car[] currentCars = [];
        foreach string key in cars.keys() {
            Car? c = cars[key];
            if c is Car {
                currentCars.push(c);
            }
        }

        return { cars: currentCars, message: "Car with the plate " + plate + " does not exist." };
    }
}


remote function SearchCar(SearchCarRequest value) returns SearchCarResponse|error {
    string plate = value.plate;

    Car? car = cars[plate]; 
    if car is Car {
        boolean isAvailable = car.status == AVAILABLE;
        return {car: car, available: isAvailable};
    } else {
        return error("Car with the plate " + plate + " does not exist.");
    }
}


    remote function AddToCart(AddToCartRequest value) returns AddToCartResponse|error {
        string username = value.username;
        string plate = value.plate;
        if !users.hasKey(username) {
            return error("User " + username + " does not exist");
        }
        Car? car = cars[plate];
        if car is () {
            return error("Car with plate " + plate + " does not exist");
        }
        if car.status != AVAILABLE {
            return error("Car is not available for rental");
        }
        if !carts.hasKey(username) {
            carts[username] = {};
        }
        CartItem newItem = {
            plate: plate,
            start_date: value.start_date,
            end_date: value.end_date
        };
        CartItem[] userCart = [];
        userCart.push(carts.get(username));
        userCart.push(newItem);
        carts[username] = userCart[0];

        return {message: "Item has been added to cart"};
    }

    remote function PlaceReservation(PlaceReservationRequest value) returns PlaceReservationResponse|error {
        string username = value.username;
        if !users.hasKey(username) {
            return error("User " + username + " does not exist");
        }
        if !carts.hasKey(username) {
            return error("No items in cart");
        }
        
        CartItem[] userCart = [];
        userCart.push(carts.get(username));
        if userCart.length() == 0 {
            return error("Cart is empty");
        }
        float totalPrice = 0;
        foreach CartItem item in userCart {
            Car? car = cars[item.plate];
            if car is Car {
                totalPrice += car.daily_price;
                car.status = RENTED;
                cars[item.plate] = car;
            }
        }
        Reservation newReservation = {
            username: username,
            items: userCart,
            total_price: totalPrice
        };
        string reservationId = username + "-" + reservations.length().toString();
        reservations[reservationId] = newReservation;
        carts[username] ={};
        
        return {
            reservation: newReservation,
            message: "Reservation placed succesfull"
        };
    }

    remote function ListAvailableCars(ListAvailableCarsRequest value) returns stream<Car, error?>|error {
        Car[] availableCars = [];
        foreach var car in cars {
            if car.status == AVAILABLE {
                if value.filter != "" {
                    if car.make.toLowerAscii().includes(value.filter.toLowerAscii()) ||
                       car.model.toLowerAscii().includes(value.filter.toLowerAscii()) {
                        availableCars.push(car);
                    }
                } else {
                    availableCars.push(car);
                }
            }
        }
        return availableCars.toStream();
    }
}

