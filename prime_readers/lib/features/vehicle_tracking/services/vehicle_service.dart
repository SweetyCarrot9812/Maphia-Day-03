import 'dart:async';
import 'dart:math' as math;
import 'package:hive_flutter/hive_flutter.dart';
import '../models/vehicle_models.dart';

class VehicleService {
  static const String _vehiclesBoxName = 'vehicles';
  static const String _driversBoxName = 'drivers';
  static const String _routesBoxName = 'routes';
  static const String _trackingBoxName = 'vehicle_tracking';
  static const String _geofencesBoxName = 'geofences';
  static const String _alertsBoxName = 'vehicle_alerts';

  late Box<Vehicle> _vehiclesBox;
  late Box<Driver> _driversBox;
  late Box<Route> _routesBox;
  late Box<VehicleTracking> _trackingBox;
  late Box<Geofence> _geofencesBox;
  late Box<VehicleAlert> _alertsBox;

  // Stream controllers for real-time updates
  final StreamController<List<VehicleTracking>> _trackingController = 
      StreamController<List<VehicleTracking>>.broadcast();
  final StreamController<List<VehicleAlert>> _alertsController = 
      StreamController<List<VehicleAlert>>.broadcast();

  Stream<List<VehicleTracking>> get trackingStream => _trackingController.stream;
  Stream<List<VehicleAlert>> get alertsStream => _alertsController.stream;

  Timer? _trackingTimer;

  Future<void> initialize() async {
    try {
      _vehiclesBox = await Hive.openBox<Vehicle>(_vehiclesBoxName);
      _driversBox = await Hive.openBox<Driver>(_driversBoxName);
      _routesBox = await Hive.openBox<Route>(_routesBoxName);
      _trackingBox = await Hive.openBox<VehicleTracking>(_trackingBoxName);
      _geofencesBox = await Hive.openBox<Geofence>(_geofencesBoxName);
      _alertsBox = await Hive.openBox<VehicleAlert>(_alertsBoxName);

      // Start real-time tracking simulation
      _startTrackingSimulation();
      
      print('VehicleService initialized successfully');
    } catch (e) {
      print('Error initializing VehicleService: $e');
      rethrow;
    }
  }

  // Vehicle Management
  Future<String> addVehicle(Vehicle vehicle) async {
    try {
      await _vehiclesBox.put(vehicle.id, vehicle);
      return vehicle.id;
    } catch (e) {
      print('Error adding vehicle: $e');
      rethrow;
    }
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    try {
      await _vehiclesBox.put(vehicle.id, vehicle);
    } catch (e) {
      print('Error updating vehicle: $e');
      rethrow;
    }
  }

  Future<void> deleteVehicle(String vehicleId) async {
    try {
      await _vehiclesBox.delete(vehicleId);
      
      // Clean up related tracking data
      await _trackingBox.delete(vehicleId);
      
      // Update routes that use this vehicle
      final routes = await getAllRoutes();
      for (final route in routes) {
        if (route.vehicleId == vehicleId) {
          final updatedRoute = route.copyWith(status: RouteStatus.cancelled);
          await _routesBox.put(route.id, updatedRoute);
        }
      }
    } catch (e) {
      print('Error deleting vehicle: $e');
      rethrow;
    }
  }

  Vehicle? getVehicle(String vehicleId) {
    return _vehiclesBox.get(vehicleId);
  }

  List<Vehicle> getAllVehicles() {
    return _vehiclesBox.values.toList();
  }

  List<Vehicle> getAvailableVehicles() {
    return _vehiclesBox.values
        .where((vehicle) => vehicle.status == VehicleStatus.active)
        .toList();
  }

  // Driver Management
  Future<String> addDriver(Driver driver) async {
    try {
      await _driversBox.put(driver.id, driver);
      return driver.id;
    } catch (e) {
      print('Error adding driver: $e');
      rethrow;
    }
  }

  Future<void> updateDriver(Driver driver) async {
    try {
      await _driversBox.put(driver.id, driver);
    } catch (e) {
      print('Error updating driver: $e');
      rethrow;
    }
  }

  Future<void> deleteDriver(String driverId) async {
    try {
      await _driversBox.delete(driverId);
      
      // Update vehicles that have this driver assigned
      final vehicles = getAllVehicles();
      for (final vehicle in vehicles) {
        if (vehicle.driverId == driverId) {
          final updatedVehicle = vehicle.copyWith(driverId: null);
          await _vehiclesBox.put(vehicle.id, updatedVehicle);
        }
      }
      
      // Update routes that use this driver
      final routes = await getAllRoutes();
      for (final route in routes) {
        if (route.driverId == driverId) {
          final updatedRoute = route.copyWith(status: RouteStatus.cancelled);
          await _routesBox.put(route.id, updatedRoute);
        }
      }
    } catch (e) {
      print('Error deleting driver: $e');
      rethrow;
    }
  }

  Driver? getDriver(String driverId) {
    return _driversBox.get(driverId);
  }

  List<Driver> getAllDrivers() {
    return _driversBox.values.toList();
  }

  List<Driver> getAvailableDrivers() {
    return _driversBox.values
        .where((driver) => driver.status == DriverStatus.available)
        .toList();
  }

  Future<void> assignDriverToVehicle(String driverId, String vehicleId) async {
    try {
      final driver = getDriver(driverId);
      final vehicle = getVehicle(vehicleId);
      
      if (driver == null || vehicle == null) {
        throw Exception('Driver or vehicle not found');
      }

      // Update driver
      final updatedDriver = driver.copyWith(
        currentVehicleId: vehicleId,
        status: DriverStatus.available,
        updatedAt: DateTime.now(),
      );
      await _driversBox.put(driverId, updatedDriver);

      // Update vehicle
      final updatedVehicle = vehicle.copyWith(
        driverId: driverId,
        updatedAt: DateTime.now(),
      );
      await _vehiclesBox.put(vehicleId, updatedVehicle);
    } catch (e) {
      print('Error assigning driver to vehicle: $e');
      rethrow;
    }
  }

  // Route Management
  Future<String> createRoute(Route route) async {
    try {
      // Validate driver and vehicle availability
      final driver = getDriver(route.driverId);
      final vehicle = getVehicle(route.vehicleId);
      
      if (driver == null || vehicle == null) {
        throw Exception('Driver or vehicle not found');
      }

      if (driver.status != DriverStatus.available) {
        throw Exception('Driver is not available');
      }

      if (vehicle.status != VehicleStatus.active) {
        throw Exception('Vehicle is not active');
      }

      await _routesBox.put(route.id, route);

      // Update driver and vehicle status
      await updateDriver(driver.copyWith(
        status: DriverStatus.on_route,
        updatedAt: DateTime.now(),
      ));

      return route.id;
    } catch (e) {
      print('Error creating route: $e');
      rethrow;
    }
  }

  Future<void> updateRoute(Route route) async {
    try {
      await _routesBox.put(route.id, route);
    } catch (e) {
      print('Error updating route: $e');
      rethrow;
    }
  }

  Future<void> startRoute(String routeId) async {
    try {
      final route = getRoute(routeId);
      if (route == null) {
        throw Exception('Route not found');
      }

      final updatedRoute = route.copyWith(
        status: RouteStatus.in_progress,
        actualStartTime: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _routesBox.put(routeId, updatedRoute);

      // Update driver status
      final driver = getDriver(route.driverId);
      if (driver != null) {
        await updateDriver(driver.copyWith(
          status: DriverStatus.on_route,
          updatedAt: DateTime.now(),
        ));
      }
    } catch (e) {
      print('Error starting route: $e');
      rethrow;
    }
  }

  Future<void> completeRoute(String routeId, double actualDistance) async {
    try {
      final route = getRoute(routeId);
      if (route == null) {
        throw Exception('Route not found');
      }

      final now = DateTime.now();
      final actualDuration = route.actualStartTime != null
          ? now.difference(route.actualStartTime!).inMinutes
          : null;

      final updatedRoute = route.copyWith(
        status: RouteStatus.completed,
        actualEndTime: now,
        actualDistance: actualDistance,
        actualDuration: actualDuration,
        updatedAt: now,
      );

      await _routesBox.put(routeId, updatedRoute);

      // Update driver status to available
      final driver = getDriver(route.driverId);
      if (driver != null) {
        await updateDriver(driver.copyWith(
          status: DriverStatus.available,
          updatedAt: now,
        ));
      }

      // Update vehicle odometer
      final vehicle = getVehicle(route.vehicleId);
      if (vehicle != null && actualDistance > 0) {
        await updateVehicle(vehicle.copyWith(
          odometer: vehicle.odometer + actualDistance.round(),
          updatedAt: now,
        ));
      }
    } catch (e) {
      print('Error completing route: $e');
      rethrow;
    }
  }

  Route? getRoute(String routeId) {
    return _routesBox.get(routeId);
  }

  Future<List<Route>> getAllRoutes() async {
    return _routesBox.values.toList();
  }

  List<Route> getActiveRoutes() {
    return _routesBox.values
        .where((route) => route.status == RouteStatus.in_progress)
        .toList();
  }

  List<Route> getScheduledRoutes() {
    return _routesBox.values
        .where((route) => route.status == RouteStatus.planned)
        .toList();
  }

  // GPS Tracking
  Future<void> updateVehicleLocation(String vehicleId, GPSLocation location) async {
    try {
      final existingTracking = _trackingBox.get(vehicleId);
      
      VehicleTracking tracking;
      if (existingTracking != null) {
        tracking = existingTracking.copyWith(
          currentLocation: location,
          lastUpdate: DateTime.now(),
        );
      } else {
        tracking = VehicleTracking(
          id: vehicleId,
          vehicleId: vehicleId,
          currentLocation: location,
          currentSpeed: location.speed ?? 0.0,
          fuelLevel: 75.0, // Default value
          engineHours: 0,
          isEngineOn: true,
          lastUpdate: DateTime.now(),
        );
      }

      await _trackingBox.put(vehicleId, tracking);
      
      // Check for geofence violations
      await _checkGeofenceViolations(vehicleId, location);
      
      // Check for speed violations
      await _checkSpeedViolations(vehicleId, location.speed ?? 0.0);
      
      // Emit updated tracking data
      _trackingController.add(_trackingBox.values.toList());
    } catch (e) {
      print('Error updating vehicle location: $e');
      rethrow;
    }
  }

  VehicleTracking? getVehicleTracking(String vehicleId) {
    return _trackingBox.get(vehicleId);
  }

  List<VehicleTracking> getAllVehicleTracking() {
    return _trackingBox.values.toList();
  }

  // Route Optimization
  Future<List<RoutePoint>> optimizeRoute(List<RoutePoint> waypoints) async {
    // Simple route optimization using nearest neighbor algorithm
    // In production, you would use a more sophisticated algorithm like:
    // - Google Maps Directions API
    // - Open Route Service
    // - Custom traveling salesman problem solver
    
    if (waypoints.length <= 2) {
      return waypoints;
    }

    final optimized = <RoutePoint>[];
    final remaining = List<RoutePoint>.from(waypoints);
    
    // Start with the first waypoint
    RoutePoint current = remaining.removeAt(0);
    optimized.add(current);
    
    while (remaining.isNotEmpty) {
      // Find nearest remaining waypoint
      double minDistance = double.infinity;
      int nearestIndex = 0;
      
      for (int i = 0; i < remaining.length; i++) {
        final distance = _calculateDistance(
          current.location.latitude,
          current.location.longitude,
          remaining[i].location.latitude,
          remaining[i].location.longitude,
        );
        
        if (distance < minDistance) {
          minDistance = distance;
          nearestIndex = i;
        }
      }
      
      current = remaining.removeAt(nearestIndex);
      optimized.add(current);
    }
    
    // Update sequence numbers
    for (int i = 0; i < optimized.length; i++) {
      final updatedPoint = RoutePoint(
        id: optimized[i].id,
        location: optimized[i].location,
        name: optimized[i].name,
        type: optimized[i].type,
        sequence: i,
        estimatedArrival: optimized[i].estimatedArrival,
        actualArrival: optimized[i].actualArrival,
        studentIds: optimized[i].studentIds,
        metadata: optimized[i].metadata,
      );
      optimized[i] = updatedPoint;
    }
    
    return optimized;
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Earth's radius in kilometers
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
        math.cos(_degreesToRadians(lat2)) *
        math.sin(dLon / 2) *
        math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  // Geofencing
  Future<String> createGeofence(Geofence geofence) async {
    try {
      await _geofencesBox.put(geofence.id, geofence);
      return geofence.id;
    } catch (e) {
      print('Error creating geofence: $e');
      rethrow;
    }
  }

  Future<void> updateGeofence(Geofence geofence) async {
    try {
      await _geofencesBox.put(geofence.id, geofence);
    } catch (e) {
      print('Error updating geofence: $e');
      rethrow;
    }
  }

  Future<void> deleteGeofence(String geofenceId) async {
    try {
      await _geofencesBox.delete(geofenceId);
    } catch (e) {
      print('Error deleting geofence: $e');
      rethrow;
    }
  }

  List<Geofence> getAllGeofences() {
    return _geofencesBox.values.toList();
  }

  Future<void> _checkGeofenceViolations(String vehicleId, GPSLocation location) async {
    final geofences = _geofencesBox.values.where((g) => 
        g.isActive && (g.vehicleIds.isEmpty || g.vehicleIds.contains(vehicleId))
    );

    for (final geofence in geofences) {
      final distance = _calculateDistance(
        location.latitude,
        location.longitude,
        geofence.center.latitude,
        geofence.center.longitude,
      ) * 1000; // Convert to meters

      final isInside = distance <= geofence.radius;
      final shouldAlert = geofence.alertSettings['alertOnExit'] == true ||
                         geofence.alertSettings['alertOnEnter'] == true;

      if (shouldAlert) {
        // Check if this is a new violation
        final recentAlerts = _alertsBox.values.where((alert) =>
          alert.vehicleId == vehicleId &&
          alert.type == (isInside ? AlertType.geofence_enter : AlertType.geofence_exit) &&
          alert.createdAt.isAfter(DateTime.now().subtract(const Duration(minutes: 5)))
        ).toList();

        if (recentAlerts.isEmpty) {
          await _createAlert(
            vehicleId: vehicleId,
            type: isInside ? AlertType.geofence_enter : AlertType.geofence_exit,
            title: isInside ? '지오펜스 진입' : '지오펜스 이탈',
            description: '차량이 ${geofence.name} ${isInside ? '구역에 진입했습니다' : '구역을 벗어났습니다'}',
            severity: 'medium',
            location: location,
          );
        }
      }
    }
  }

  Future<void> _checkSpeedViolations(String vehicleId, double speed) async {
    const speedLimit = 80.0; // km/h
    
    if (speed > speedLimit) {
      // Check if there's a recent speeding alert
      final recentSpeedingAlerts = _alertsBox.values.where((alert) =>
        alert.vehicleId == vehicleId &&
        alert.type == AlertType.speeding &&
        alert.createdAt.isAfter(DateTime.now().subtract(const Duration(minutes: 5)))
      ).toList();

      if (recentSpeedingAlerts.isEmpty) {
        await _createAlert(
          vehicleId: vehicleId,
          type: AlertType.speeding,
          title: '속도 위반',
          description: '차량이 제한속도(${speedLimit.toInt()}km/h)를 초과했습니다. 현재 속도: ${speed.toInt()}km/h',
          severity: 'high',
        );
      }
    }
  }

  // Alert Management
  Future<String> _createAlert({
    required String vehicleId,
    String? driverId,
    required AlertType type,
    required String title,
    required String description,
    required String severity,
    GPSLocation? location,
  }) async {
    try {
      final alert = VehicleAlert(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        vehicleId: vehicleId,
        driverId: driverId,
        type: type,
        title: title,
        description: description,
        severity: severity,
        location: location,
        isResolved: false,
        createdAt: DateTime.now(),
      );

      await _alertsBox.put(alert.id, alert);
      
      // Emit updated alerts
      _alertsController.add(_alertsBox.values.toList());
      
      return alert.id;
    } catch (e) {
      print('Error creating alert: $e');
      rethrow;
    }
  }

  Future<void> resolveAlert(String alertId, String resolvedBy) async {
    try {
      final alert = _alertsBox.get(alertId);
      if (alert == null) {
        throw Exception('Alert not found');
      }

      final updatedAlert = alert.copyWith(
        isResolved: true,
        resolvedAt: DateTime.now(),
        resolvedBy: resolvedBy,
      );

      await _alertsBox.put(alertId, updatedAlert);
      
      // Emit updated alerts
      _alertsController.add(_alertsBox.values.toList());
    } catch (e) {
      print('Error resolving alert: $e');
      rethrow;
    }
  }

  List<VehicleAlert> getAllAlerts() {
    return _alertsBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<VehicleAlert> getUnresolvedAlerts() {
    return _alertsBox.values
        .where((alert) => !alert.isResolved)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<VehicleAlert> getVehicleAlerts(String vehicleId) {
    return _alertsBox.values
        .where((alert) => alert.vehicleId == vehicleId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Real-time tracking simulation
  void _startTrackingSimulation() {
    _trackingTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      await _simulateVehicleMovement();
    });
  }

  Future<void> _simulateVehicleMovement() async {
    final vehicles = getAllVehicles();
    final random = math.Random();
    
    for (final vehicle in vehicles) {
      if (vehicle.status == VehicleStatus.active) {
        final tracking = getVehicleTracking(vehicle.id);
        
        GPSLocation newLocation;
        if (tracking != null) {
          // Simulate small movement
          final latDelta = (random.nextDouble() - 0.5) * 0.001;
          final lonDelta = (random.nextDouble() - 0.5) * 0.001;
          
          newLocation = GPSLocation(
            latitude: tracking.currentLocation.latitude + latDelta,
            longitude: tracking.currentLocation.longitude + lonDelta,
            speed: random.nextDouble() * 60, // 0-60 km/h
            heading: random.nextDouble() * 360,
            accuracy: 5.0,
            timestamp: DateTime.now(),
          );
        } else {
          // Random starting location (Seoul area)
          newLocation = GPSLocation(
            latitude: 37.5665 + (random.nextDouble() - 0.5) * 0.1,
            longitude: 126.9780 + (random.nextDouble() - 0.5) * 0.1,
            speed: random.nextDouble() * 60,
            heading: random.nextDouble() * 360,
            accuracy: 5.0,
            timestamp: DateTime.now(),
          );
        }
        
        await updateVehicleLocation(vehicle.id, newLocation);
      }
    }
  }

  // Sample data for demo
  Future<void> addSampleData() async {
    try {
      if (_vehiclesBox.isEmpty) {
        // Sample vehicles
        final sampleVehicles = [
          Vehicle(
            id: 'vehicle_1',
            licensePlate: '서울12가3456',
            type: VehicleType.bus,
            status: VehicleStatus.active,
            make: '현대',
            model: '유니버스',
            year: 2020,
            capacity: 45,
            fuelCapacity: 200.0,
            currentFuelLevel: 75.0,
            lastMaintenanceDate: DateTime.now().subtract(const Duration(days: 30)),
            nextMaintenanceDate: DateTime.now().add(const Duration(days: 60)),
            odometer: 50000,
            color: '파란색',
            createdAt: DateTime.now().subtract(const Duration(days: 100)),
            updatedAt: DateTime.now(),
          ),
          Vehicle(
            id: 'vehicle_2',
            licensePlate: '경기34나5678',
            type: VehicleType.van,
            status: VehicleStatus.active,
            make: '기아',
            model: '카니발',
            year: 2021,
            capacity: 11,
            fuelCapacity: 80.0,
            currentFuelLevel: 60.0,
            lastMaintenanceDate: DateTime.now().subtract(const Duration(days: 15)),
            nextMaintenanceDate: DateTime.now().add(const Duration(days: 75)),
            odometer: 25000,
            color: '흰색',
            createdAt: DateTime.now().subtract(const Duration(days: 80)),
            updatedAt: DateTime.now(),
          ),
        ];

        for (final vehicle in sampleVehicles) {
          await addVehicle(vehicle);
        }

        // Sample drivers
        final sampleDrivers = [
          Driver(
            id: 'driver_1',
            name: '김운전',
            phoneNumber: '010-1234-5678',
            email: 'kim.driver@example.com',
            licenseNumber: '11-12-345678-90',
            licenseExpiryDate: DateTime.now().add(const Duration(days: 365)),
            status: DriverStatus.available,
            experienceYears: 15,
            rating: 4.8,
            hireDate: DateTime.now().subtract(const Duration(days: 1500)),
            createdAt: DateTime.now().subtract(const Duration(days: 100)),
            updatedAt: DateTime.now(),
          ),
          Driver(
            id: 'driver_2',
            name: '박기사',
            phoneNumber: '010-9876-5432',
            email: 'park.driver@example.com',
            licenseNumber: '22-34-567890-12',
            licenseExpiryDate: DateTime.now().add(const Duration(days: 500)),
            status: DriverStatus.available,
            experienceYears: 8,
            rating: 4.6,
            hireDate: DateTime.now().subtract(const Duration(days: 800)),
            createdAt: DateTime.now().subtract(const Duration(days: 80)),
            updatedAt: DateTime.now(),
          ),
        ];

        for (final driver in sampleDrivers) {
          await addDriver(driver);
        }

        // Assign drivers to vehicles
        await assignDriverToVehicle('driver_1', 'vehicle_1');
        await assignDriverToVehicle('driver_2', 'vehicle_2');

        // Sample geofences
        final sampleGeofences = [
          Geofence(
            id: 'geofence_1',
            name: '프라임 리더스 학교',
            type: GeofenceType.school,
            center: GPSLocation(
              latitude: 37.5665,
              longitude: 126.9780,
              timestamp: DateTime.now(),
            ),
            radius: 500.0, // 500 meters
            isActive: true,
            alertSettings: {
              'alertOnEnter': true,
              'alertOnExit': true,
            },
            createdAt: DateTime.now(),
          ),
          Geofence(
            id: 'geofence_2',
            name: '안전 구역',
            type: GeofenceType.safe_zone,
            center: GPSLocation(
              latitude: 37.5515,
              longitude: 126.9880,
              timestamp: DateTime.now(),
            ),
            radius: 1000.0, // 1 km
            isActive: true,
            alertSettings: {
              'alertOnExit': true,
            },
            createdAt: DateTime.now(),
          ),
        ];

        for (final geofence in sampleGeofences) {
          await createGeofence(geofence);
        }

        print('Sample vehicle tracking data added successfully');
      }
    } catch (e) {
      print('Error adding sample data: $e');
    }
  }

  void dispose() {
    _trackingTimer?.cancel();
    _trackingController.close();
    _alertsController.close();
  }
}