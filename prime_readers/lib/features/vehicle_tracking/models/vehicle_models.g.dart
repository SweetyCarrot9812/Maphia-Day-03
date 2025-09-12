// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VehicleAdapter extends TypeAdapter<Vehicle> {
  @override
  final int typeId = 86;

  @override
  Vehicle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Vehicle(
      id: fields[0] as String,
      licensePlate: fields[1] as String,
      type: fields[2] as VehicleType,
      status: fields[3] as VehicleStatus,
      make: fields[4] as String,
      model: fields[5] as String,
      year: fields[6] as int,
      capacity: fields[7] as int,
      driverId: fields[8] as String?,
      fuelCapacity: fields[9] as double,
      currentFuelLevel: fields[10] as double,
      lastMaintenanceDate: fields[11] as DateTime,
      nextMaintenanceDate: fields[12] as DateTime,
      odometer: fields[13] as int,
      color: fields[14] as String,
      imageUrl: fields[15] as String?,
      metadata: (fields[16] as Map).cast<String, dynamic>(),
      createdAt: fields[17] as DateTime,
      updatedAt: fields[18] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Vehicle obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.licensePlate)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.make)
      ..writeByte(5)
      ..write(obj.model)
      ..writeByte(6)
      ..write(obj.year)
      ..writeByte(7)
      ..write(obj.capacity)
      ..writeByte(8)
      ..write(obj.driverId)
      ..writeByte(9)
      ..write(obj.fuelCapacity)
      ..writeByte(10)
      ..write(obj.currentFuelLevel)
      ..writeByte(11)
      ..write(obj.lastMaintenanceDate)
      ..writeByte(12)
      ..write(obj.nextMaintenanceDate)
      ..writeByte(13)
      ..write(obj.odometer)
      ..writeByte(14)
      ..write(obj.color)
      ..writeByte(15)
      ..write(obj.imageUrl)
      ..writeByte(16)
      ..write(obj.metadata)
      ..writeByte(17)
      ..write(obj.createdAt)
      ..writeByte(18)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DriverAdapter extends TypeAdapter<Driver> {
  @override
  final int typeId = 87;

  @override
  Driver read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Driver(
      id: fields[0] as String,
      name: fields[1] as String,
      phoneNumber: fields[2] as String,
      email: fields[3] as String,
      licenseNumber: fields[4] as String,
      licenseExpiryDate: fields[5] as DateTime,
      status: fields[6] as DriverStatus,
      currentVehicleId: fields[7] as String?,
      experienceYears: fields[8] as int,
      rating: fields[9] as double,
      profileImageUrl: fields[10] as String?,
      certifications: (fields[11] as List).cast<String>(),
      hireDate: fields[12] as DateTime,
      emergencyContact: (fields[13] as Map).cast<String, dynamic>(),
      metadata: (fields[14] as Map).cast<String, dynamic>(),
      createdAt: fields[15] as DateTime,
      updatedAt: fields[16] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Driver obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.phoneNumber)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.licenseNumber)
      ..writeByte(5)
      ..write(obj.licenseExpiryDate)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.currentVehicleId)
      ..writeByte(8)
      ..write(obj.experienceYears)
      ..writeByte(9)
      ..write(obj.rating)
      ..writeByte(10)
      ..write(obj.profileImageUrl)
      ..writeByte(11)
      ..write(obj.certifications)
      ..writeByte(12)
      ..write(obj.hireDate)
      ..writeByte(13)
      ..write(obj.emergencyContact)
      ..writeByte(14)
      ..write(obj.metadata)
      ..writeByte(15)
      ..write(obj.createdAt)
      ..writeByte(16)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GPSLocationAdapter extends TypeAdapter<GPSLocation> {
  @override
  final int typeId = 88;

  @override
  GPSLocation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GPSLocation(
      latitude: fields[0] as double,
      longitude: fields[1] as double,
      altitude: fields[2] as double?,
      speed: fields[3] as double?,
      heading: fields[4] as double?,
      accuracy: fields[5] as double?,
      timestamp: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, GPSLocation obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.latitude)
      ..writeByte(1)
      ..write(obj.longitude)
      ..writeByte(2)
      ..write(obj.altitude)
      ..writeByte(3)
      ..write(obj.speed)
      ..writeByte(4)
      ..write(obj.heading)
      ..writeByte(5)
      ..write(obj.accuracy)
      ..writeByte(6)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GPSLocationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RouteAdapter extends TypeAdapter<Route> {
  @override
  final int typeId = 89;

  @override
  Route read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Route(
      id: fields[0] as String,
      name: fields[1] as String,
      vehicleId: fields[2] as String,
      driverId: fields[3] as String,
      status: fields[4] as RouteStatus,
      waypoints: (fields[5] as List).cast<RoutePoint>(),
      scheduledStartTime: fields[6] as DateTime,
      scheduledEndTime: fields[7] as DateTime,
      actualStartTime: fields[8] as DateTime?,
      actualEndTime: fields[9] as DateTime?,
      estimatedDistance: fields[10] as double,
      actualDistance: fields[11] as double?,
      estimatedDuration: fields[12] as int,
      actualDuration: fields[13] as int?,
      studentIds: (fields[14] as List).cast<String>(),
      metadata: (fields[15] as Map).cast<String, dynamic>(),
      createdAt: fields[16] as DateTime,
      updatedAt: fields[17] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Route obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.vehicleId)
      ..writeByte(3)
      ..write(obj.driverId)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.waypoints)
      ..writeByte(6)
      ..write(obj.scheduledStartTime)
      ..writeByte(7)
      ..write(obj.scheduledEndTime)
      ..writeByte(8)
      ..write(obj.actualStartTime)
      ..writeByte(9)
      ..write(obj.actualEndTime)
      ..writeByte(10)
      ..write(obj.estimatedDistance)
      ..writeByte(11)
      ..write(obj.actualDistance)
      ..writeByte(12)
      ..write(obj.estimatedDuration)
      ..writeByte(13)
      ..write(obj.actualDuration)
      ..writeByte(14)
      ..write(obj.studentIds)
      ..writeByte(15)
      ..write(obj.metadata)
      ..writeByte(16)
      ..write(obj.createdAt)
      ..writeByte(17)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RoutePointAdapter extends TypeAdapter<RoutePoint> {
  @override
  final int typeId = 90;

  @override
  RoutePoint read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RoutePoint(
      id: fields[0] as String,
      location: fields[1] as GPSLocation,
      name: fields[2] as String,
      type: fields[3] as String,
      sequence: fields[4] as int,
      estimatedArrival: fields[5] as DateTime?,
      actualArrival: fields[6] as DateTime?,
      studentIds: (fields[7] as List).cast<String>(),
      metadata: (fields[8] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, RoutePoint obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.location)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.sequence)
      ..writeByte(5)
      ..write(obj.estimatedArrival)
      ..writeByte(6)
      ..write(obj.actualArrival)
      ..writeByte(7)
      ..write(obj.studentIds)
      ..writeByte(8)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoutePointAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class VehicleTrackingAdapter extends TypeAdapter<VehicleTracking> {
  @override
  final int typeId = 91;

  @override
  VehicleTracking read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VehicleTracking(
      id: fields[0] as String,
      vehicleId: fields[1] as String,
      currentLocation: fields[2] as GPSLocation,
      currentRouteId: fields[3] as String?,
      currentSpeed: fields[4] as double,
      fuelLevel: fields[5] as double,
      engineHours: fields[6] as int,
      isEngineOn: fields[7] as bool,
      diagnostics: (fields[8] as Map).cast<String, dynamic>(),
      lastUpdate: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, VehicleTracking obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.vehicleId)
      ..writeByte(2)
      ..write(obj.currentLocation)
      ..writeByte(3)
      ..write(obj.currentRouteId)
      ..writeByte(4)
      ..write(obj.currentSpeed)
      ..writeByte(5)
      ..write(obj.fuelLevel)
      ..writeByte(6)
      ..write(obj.engineHours)
      ..writeByte(7)
      ..write(obj.isEngineOn)
      ..writeByte(8)
      ..write(obj.diagnostics)
      ..writeByte(9)
      ..write(obj.lastUpdate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleTrackingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GeofenceAdapter extends TypeAdapter<Geofence> {
  @override
  final int typeId = 92;

  @override
  Geofence read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Geofence(
      id: fields[0] as String,
      name: fields[1] as String,
      type: fields[2] as GeofenceType,
      center: fields[3] as GPSLocation,
      radius: fields[4] as double,
      isActive: fields[5] as bool,
      vehicleIds: (fields[6] as List).cast<String>(),
      alertSettings: (fields[7] as Map).cast<String, dynamic>(),
      metadata: (fields[8] as Map).cast<String, dynamic>(),
      createdAt: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Geofence obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.center)
      ..writeByte(4)
      ..write(obj.radius)
      ..writeByte(5)
      ..write(obj.isActive)
      ..writeByte(6)
      ..write(obj.vehicleIds)
      ..writeByte(7)
      ..write(obj.alertSettings)
      ..writeByte(8)
      ..write(obj.metadata)
      ..writeByte(9)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeofenceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class VehicleAlertAdapter extends TypeAdapter<VehicleAlert> {
  @override
  final int typeId = 93;

  @override
  VehicleAlert read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VehicleAlert(
      id: fields[0] as String,
      vehicleId: fields[1] as String,
      driverId: fields[2] as String?,
      type: fields[3] as AlertType,
      title: fields[4] as String,
      description: fields[5] as String,
      severity: fields[6] as String,
      location: fields[7] as GPSLocation?,
      isResolved: fields[8] as bool,
      resolvedAt: fields[9] as DateTime?,
      resolvedBy: fields[10] as String?,
      metadata: (fields[11] as Map).cast<String, dynamic>(),
      createdAt: fields[12] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, VehicleAlert obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.vehicleId)
      ..writeByte(2)
      ..write(obj.driverId)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.title)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.severity)
      ..writeByte(7)
      ..write(obj.location)
      ..writeByte(8)
      ..write(obj.isResolved)
      ..writeByte(9)
      ..write(obj.resolvedAt)
      ..writeByte(10)
      ..write(obj.resolvedBy)
      ..writeByte(11)
      ..write(obj.metadata)
      ..writeByte(12)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleAlertAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class VehicleStatusAdapter extends TypeAdapter<VehicleStatus> {
  @override
  final int typeId = 80;

  @override
  VehicleStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return VehicleStatus.active;
      case 1:
        return VehicleStatus.inactive;
      case 2:
        return VehicleStatus.maintenance;
      case 3:
        return VehicleStatus.out_of_service;
      default:
        return VehicleStatus.active;
    }
  }

  @override
  void write(BinaryWriter writer, VehicleStatus obj) {
    switch (obj) {
      case VehicleStatus.active:
        writer.writeByte(0);
        break;
      case VehicleStatus.inactive:
        writer.writeByte(1);
        break;
      case VehicleStatus.maintenance:
        writer.writeByte(2);
        break;
      case VehicleStatus.out_of_service:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class VehicleTypeAdapter extends TypeAdapter<VehicleType> {
  @override
  final int typeId = 81;

  @override
  VehicleType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return VehicleType.bus;
      case 1:
        return VehicleType.van;
      case 2:
        return VehicleType.car;
      case 3:
        return VehicleType.mini_bus;
      default:
        return VehicleType.bus;
    }
  }

  @override
  void write(BinaryWriter writer, VehicleType obj) {
    switch (obj) {
      case VehicleType.bus:
        writer.writeByte(0);
        break;
      case VehicleType.van:
        writer.writeByte(1);
        break;
      case VehicleType.car:
        writer.writeByte(2);
        break;
      case VehicleType.mini_bus:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DriverStatusAdapter extends TypeAdapter<DriverStatus> {
  @override
  final int typeId = 82;

  @override
  DriverStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DriverStatus.available;
      case 1:
        return DriverStatus.on_route;
      case 2:
        return DriverStatus.break_time;
      case 3:
        return DriverStatus.off_duty;
      default:
        return DriverStatus.available;
    }
  }

  @override
  void write(BinaryWriter writer, DriverStatus obj) {
    switch (obj) {
      case DriverStatus.available:
        writer.writeByte(0);
        break;
      case DriverStatus.on_route:
        writer.writeByte(1);
        break;
      case DriverStatus.break_time:
        writer.writeByte(2);
        break;
      case DriverStatus.off_duty:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RouteStatusAdapter extends TypeAdapter<RouteStatus> {
  @override
  final int typeId = 83;

  @override
  RouteStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RouteStatus.planned;
      case 1:
        return RouteStatus.in_progress;
      case 2:
        return RouteStatus.completed;
      case 3:
        return RouteStatus.cancelled;
      case 4:
        return RouteStatus.delayed;
      default:
        return RouteStatus.planned;
    }
  }

  @override
  void write(BinaryWriter writer, RouteStatus obj) {
    switch (obj) {
      case RouteStatus.planned:
        writer.writeByte(0);
        break;
      case RouteStatus.in_progress:
        writer.writeByte(1);
        break;
      case RouteStatus.completed:
        writer.writeByte(2);
        break;
      case RouteStatus.cancelled:
        writer.writeByte(3);
        break;
      case RouteStatus.delayed:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouteStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AlertTypeAdapter extends TypeAdapter<AlertType> {
  @override
  final int typeId = 84;

  @override
  AlertType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AlertType.speeding;
      case 1:
        return AlertType.geofence_exit;
      case 2:
        return AlertType.geofence_enter;
      case 3:
        return AlertType.maintenance_due;
      case 4:
        return AlertType.fuel_low;
      case 5:
        return AlertType.route_deviation;
      case 6:
        return AlertType.emergency;
      default:
        return AlertType.speeding;
    }
  }

  @override
  void write(BinaryWriter writer, AlertType obj) {
    switch (obj) {
      case AlertType.speeding:
        writer.writeByte(0);
        break;
      case AlertType.geofence_exit:
        writer.writeByte(1);
        break;
      case AlertType.geofence_enter:
        writer.writeByte(2);
        break;
      case AlertType.maintenance_due:
        writer.writeByte(3);
        break;
      case AlertType.fuel_low:
        writer.writeByte(4);
        break;
      case AlertType.route_deviation:
        writer.writeByte(5);
        break;
      case AlertType.emergency:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlertTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GeofenceTypeAdapter extends TypeAdapter<GeofenceType> {
  @override
  final int typeId = 85;

  @override
  GeofenceType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GeofenceType.school;
      case 1:
        return GeofenceType.pickup_point;
      case 2:
        return GeofenceType.safe_zone;
      case 3:
        return GeofenceType.restricted_zone;
      default:
        return GeofenceType.school;
    }
  }

  @override
  void write(BinaryWriter writer, GeofenceType obj) {
    switch (obj) {
      case GeofenceType.school:
        writer.writeByte(0);
        break;
      case GeofenceType.pickup_point:
        writer.writeByte(1);
        break;
      case GeofenceType.safe_zone:
        writer.writeByte(2);
        break;
      case GeofenceType.restricted_zone:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeofenceTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Vehicle _$VehicleFromJson(Map<String, dynamic> json) => Vehicle(
      id: json['id'] as String,
      licensePlate: json['licensePlate'] as String,
      type: $enumDecode(_$VehicleTypeEnumMap, json['type']),
      status: $enumDecode(_$VehicleStatusEnumMap, json['status']),
      make: json['make'] as String,
      model: json['model'] as String,
      year: (json['year'] as num).toInt(),
      capacity: (json['capacity'] as num).toInt(),
      driverId: json['driverId'] as String?,
      fuelCapacity: (json['fuelCapacity'] as num).toDouble(),
      currentFuelLevel: (json['currentFuelLevel'] as num).toDouble(),
      lastMaintenanceDate:
          DateTime.parse(json['lastMaintenanceDate'] as String),
      nextMaintenanceDate:
          DateTime.parse(json['nextMaintenanceDate'] as String),
      odometer: (json['odometer'] as num).toInt(),
      color: json['color'] as String,
      imageUrl: json['imageUrl'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$VehicleToJson(Vehicle instance) => <String, dynamic>{
      'id': instance.id,
      'licensePlate': instance.licensePlate,
      'type': _$VehicleTypeEnumMap[instance.type]!,
      'status': _$VehicleStatusEnumMap[instance.status]!,
      'make': instance.make,
      'model': instance.model,
      'year': instance.year,
      'capacity': instance.capacity,
      'driverId': instance.driverId,
      'fuelCapacity': instance.fuelCapacity,
      'currentFuelLevel': instance.currentFuelLevel,
      'lastMaintenanceDate': instance.lastMaintenanceDate.toIso8601String(),
      'nextMaintenanceDate': instance.nextMaintenanceDate.toIso8601String(),
      'odometer': instance.odometer,
      'color': instance.color,
      'imageUrl': instance.imageUrl,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$VehicleTypeEnumMap = {
  VehicleType.bus: 'bus',
  VehicleType.van: 'van',
  VehicleType.car: 'car',
  VehicleType.mini_bus: 'mini_bus',
};

const _$VehicleStatusEnumMap = {
  VehicleStatus.active: 'active',
  VehicleStatus.inactive: 'inactive',
  VehicleStatus.maintenance: 'maintenance',
  VehicleStatus.out_of_service: 'out_of_service',
};

Driver _$DriverFromJson(Map<String, dynamic> json) => Driver(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String,
      licenseNumber: json['licenseNumber'] as String,
      licenseExpiryDate: DateTime.parse(json['licenseExpiryDate'] as String),
      status: $enumDecode(_$DriverStatusEnumMap, json['status']),
      currentVehicleId: json['currentVehicleId'] as String?,
      experienceYears: (json['experienceYears'] as num).toInt(),
      rating: (json['rating'] as num).toDouble(),
      profileImageUrl: json['profileImageUrl'] as String?,
      certifications: (json['certifications'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      hireDate: DateTime.parse(json['hireDate'] as String),
      emergencyContact:
          json['emergencyContact'] as Map<String, dynamic>? ?? const {},
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$DriverToJson(Driver instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phoneNumber': instance.phoneNumber,
      'email': instance.email,
      'licenseNumber': instance.licenseNumber,
      'licenseExpiryDate': instance.licenseExpiryDate.toIso8601String(),
      'status': _$DriverStatusEnumMap[instance.status]!,
      'currentVehicleId': instance.currentVehicleId,
      'experienceYears': instance.experienceYears,
      'rating': instance.rating,
      'profileImageUrl': instance.profileImageUrl,
      'certifications': instance.certifications,
      'hireDate': instance.hireDate.toIso8601String(),
      'emergencyContact': instance.emergencyContact,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$DriverStatusEnumMap = {
  DriverStatus.available: 'available',
  DriverStatus.on_route: 'on_route',
  DriverStatus.break_time: 'break_time',
  DriverStatus.off_duty: 'off_duty',
};

GPSLocation _$GPSLocationFromJson(Map<String, dynamic> json) => GPSLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      altitude: (json['altitude'] as num?)?.toDouble(),
      speed: (json['speed'] as num?)?.toDouble(),
      heading: (json['heading'] as num?)?.toDouble(),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$GPSLocationToJson(GPSLocation instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'altitude': instance.altitude,
      'speed': instance.speed,
      'heading': instance.heading,
      'accuracy': instance.accuracy,
      'timestamp': instance.timestamp.toIso8601String(),
    };

Route _$RouteFromJson(Map<String, dynamic> json) => Route(
      id: json['id'] as String,
      name: json['name'] as String,
      vehicleId: json['vehicleId'] as String,
      driverId: json['driverId'] as String,
      status: $enumDecode(_$RouteStatusEnumMap, json['status']),
      waypoints: (json['waypoints'] as List<dynamic>)
          .map((e) => RoutePoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      scheduledStartTime: DateTime.parse(json['scheduledStartTime'] as String),
      scheduledEndTime: DateTime.parse(json['scheduledEndTime'] as String),
      actualStartTime: json['actualStartTime'] == null
          ? null
          : DateTime.parse(json['actualStartTime'] as String),
      actualEndTime: json['actualEndTime'] == null
          ? null
          : DateTime.parse(json['actualEndTime'] as String),
      estimatedDistance: (json['estimatedDistance'] as num).toDouble(),
      actualDistance: (json['actualDistance'] as num?)?.toDouble(),
      estimatedDuration: (json['estimatedDuration'] as num).toInt(),
      actualDuration: (json['actualDuration'] as num?)?.toInt(),
      studentIds: (json['studentIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$RouteToJson(Route instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'vehicleId': instance.vehicleId,
      'driverId': instance.driverId,
      'status': _$RouteStatusEnumMap[instance.status]!,
      'waypoints': instance.waypoints,
      'scheduledStartTime': instance.scheduledStartTime.toIso8601String(),
      'scheduledEndTime': instance.scheduledEndTime.toIso8601String(),
      'actualStartTime': instance.actualStartTime?.toIso8601String(),
      'actualEndTime': instance.actualEndTime?.toIso8601String(),
      'estimatedDistance': instance.estimatedDistance,
      'actualDistance': instance.actualDistance,
      'estimatedDuration': instance.estimatedDuration,
      'actualDuration': instance.actualDuration,
      'studentIds': instance.studentIds,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$RouteStatusEnumMap = {
  RouteStatus.planned: 'planned',
  RouteStatus.in_progress: 'in_progress',
  RouteStatus.completed: 'completed',
  RouteStatus.cancelled: 'cancelled',
  RouteStatus.delayed: 'delayed',
};

RoutePoint _$RoutePointFromJson(Map<String, dynamic> json) => RoutePoint(
      id: json['id'] as String,
      location: GPSLocation.fromJson(json['location'] as Map<String, dynamic>),
      name: json['name'] as String,
      type: json['type'] as String,
      sequence: (json['sequence'] as num).toInt(),
      estimatedArrival: json['estimatedArrival'] == null
          ? null
          : DateTime.parse(json['estimatedArrival'] as String),
      actualArrival: json['actualArrival'] == null
          ? null
          : DateTime.parse(json['actualArrival'] as String),
      studentIds: (json['studentIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$RoutePointToJson(RoutePoint instance) =>
    <String, dynamic>{
      'id': instance.id,
      'location': instance.location,
      'name': instance.name,
      'type': instance.type,
      'sequence': instance.sequence,
      'estimatedArrival': instance.estimatedArrival?.toIso8601String(),
      'actualArrival': instance.actualArrival?.toIso8601String(),
      'studentIds': instance.studentIds,
      'metadata': instance.metadata,
    };

VehicleTracking _$VehicleTrackingFromJson(Map<String, dynamic> json) =>
    VehicleTracking(
      id: json['id'] as String,
      vehicleId: json['vehicleId'] as String,
      currentLocation:
          GPSLocation.fromJson(json['currentLocation'] as Map<String, dynamic>),
      currentRouteId: json['currentRouteId'] as String?,
      currentSpeed: (json['currentSpeed'] as num).toDouble(),
      fuelLevel: (json['fuelLevel'] as num).toDouble(),
      engineHours: (json['engineHours'] as num).toInt(),
      isEngineOn: json['isEngineOn'] as bool,
      diagnostics: json['diagnostics'] as Map<String, dynamic>? ?? const {},
      lastUpdate: DateTime.parse(json['lastUpdate'] as String),
    );

Map<String, dynamic> _$VehicleTrackingToJson(VehicleTracking instance) =>
    <String, dynamic>{
      'id': instance.id,
      'vehicleId': instance.vehicleId,
      'currentLocation': instance.currentLocation,
      'currentRouteId': instance.currentRouteId,
      'currentSpeed': instance.currentSpeed,
      'fuelLevel': instance.fuelLevel,
      'engineHours': instance.engineHours,
      'isEngineOn': instance.isEngineOn,
      'diagnostics': instance.diagnostics,
      'lastUpdate': instance.lastUpdate.toIso8601String(),
    };

Geofence _$GeofenceFromJson(Map<String, dynamic> json) => Geofence(
      id: json['id'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$GeofenceTypeEnumMap, json['type']),
      center: GPSLocation.fromJson(json['center'] as Map<String, dynamic>),
      radius: (json['radius'] as num).toDouble(),
      isActive: json['isActive'] as bool,
      vehicleIds: (json['vehicleIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      alertSettings: json['alertSettings'] as Map<String, dynamic>? ?? const {},
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$GeofenceToJson(Geofence instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$GeofenceTypeEnumMap[instance.type]!,
      'center': instance.center,
      'radius': instance.radius,
      'isActive': instance.isActive,
      'vehicleIds': instance.vehicleIds,
      'alertSettings': instance.alertSettings,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$GeofenceTypeEnumMap = {
  GeofenceType.school: 'school',
  GeofenceType.pickup_point: 'pickup_point',
  GeofenceType.safe_zone: 'safe_zone',
  GeofenceType.restricted_zone: 'restricted_zone',
};

VehicleAlert _$VehicleAlertFromJson(Map<String, dynamic> json) => VehicleAlert(
      id: json['id'] as String,
      vehicleId: json['vehicleId'] as String,
      driverId: json['driverId'] as String?,
      type: $enumDecode(_$AlertTypeEnumMap, json['type']),
      title: json['title'] as String,
      description: json['description'] as String,
      severity: json['severity'] as String,
      location: json['location'] == null
          ? null
          : GPSLocation.fromJson(json['location'] as Map<String, dynamic>),
      isResolved: json['isResolved'] as bool,
      resolvedAt: json['resolvedAt'] == null
          ? null
          : DateTime.parse(json['resolvedAt'] as String),
      resolvedBy: json['resolvedBy'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$VehicleAlertToJson(VehicleAlert instance) =>
    <String, dynamic>{
      'id': instance.id,
      'vehicleId': instance.vehicleId,
      'driverId': instance.driverId,
      'type': _$AlertTypeEnumMap[instance.type]!,
      'title': instance.title,
      'description': instance.description,
      'severity': instance.severity,
      'location': instance.location,
      'isResolved': instance.isResolved,
      'resolvedAt': instance.resolvedAt?.toIso8601String(),
      'resolvedBy': instance.resolvedBy,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$AlertTypeEnumMap = {
  AlertType.speeding: 'speeding',
  AlertType.geofence_exit: 'geofence_exit',
  AlertType.geofence_enter: 'geofence_enter',
  AlertType.maintenance_due: 'maintenance_due',
  AlertType.fuel_low: 'fuel_low',
  AlertType.route_deviation: 'route_deviation',
  AlertType.emergency: 'emergency',
};
