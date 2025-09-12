import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/vehicle_models.dart' as models;
import '../services/vehicle_service.dart';

// Providers for vehicle tracking system
final vehicleServiceProvider = Provider<VehicleService>((ref) => VehicleService());

final vehiclesProvider = FutureProvider<List<models.Vehicle>>((ref) async {
  final service = ref.read(vehicleServiceProvider);
  await service.initialize();
  return service.getAllVehicles();
});

final activeRoutesProvider = FutureProvider<List<models.Route>>((ref) async {
  final service = ref.read(vehicleServiceProvider);
  await service.initialize();
  return service.getActiveRoutes();
});

final vehicleTrackingProvider = StreamProvider<List<models.VehicleTracking>>((ref) {
  final service = ref.read(vehicleServiceProvider);
  return service.trackingStream;
});

final vehicleAlertsProvider = StreamProvider<List<models.VehicleAlert>>((ref) {
  final service = ref.read(vehicleServiceProvider);
  return service.alertsStream;
});

class VehicleTrackingScreen extends ConsumerStatefulWidget {
  const VehicleTrackingScreen({super.key});

  @override
  ConsumerState<VehicleTrackingScreen> createState() => _VehicleTrackingScreenState();
}

class _VehicleTrackingScreenState extends ConsumerState<VehicleTrackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '차량 추적 시스템',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.map),
              text: '실시간 추적',
            ),
            Tab(
              icon: const Icon(Icons.directions_bus),
              text: '차량 관리',
            ),
            Tab(
              icon: const Icon(Icons.route),
              text: '경로 관리',
            ),
            Tab(
              icon: const Icon(Icons.warning),
              text: '알림',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const RealTimeTrackingTab(),
          const VehicleManagementTab(),
          const RouteManagementTab(),
          const AlertsTab(),
        ],
      ),
    );
  }
}

// Real-time tracking tab
class RealTimeTrackingTab extends ConsumerWidget {
  const RealTimeTrackingTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackingAsync = ref.watch(vehicleTrackingProvider);
    final vehiclesAsync = ref.watch(vehiclesProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.refresh(vehicleTrackingProvider);
        ref.refresh(vehiclesProvider);
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary cards
            _buildSummaryCards(context, vehiclesAsync, trackingAsync),
            SizedBox(height: 24.h),
            
            // Vehicle tracking list
            Text(
              '실시간 차량 위치',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            
            trackingAsync.when(
              data: (trackingList) => vehiclesAsync.when(
                data: (vehicles) => _buildTrackingList(context, trackingList, vehicles),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildErrorWidget('차량 정보를 불러오는 중 오류가 발생했습니다.'),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildErrorWidget('실시간 추적 정보를 불러오는 중 오류가 발생했습니다.'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(
    BuildContext context,
    AsyncValue<List<models.Vehicle>> vehiclesAsync,
    AsyncValue<List<models.VehicleTracking>> trackingAsync,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            context,
            title: '전체 차량',
            value: vehiclesAsync.when(
              data: (vehicles) => vehicles.length.toString(),
              loading: () => '...',
              error: (_, __) => '0',
            ),
            icon: Icons.directions_bus,
            color: Colors.blue,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _buildSummaryCard(
            context,
            title: '운행 중',
            value: trackingAsync.when(
              data: (tracking) => tracking.where((t) => t.isEngineOn).length.toString(),
              loading: () => '...',
              error: (_, __) => '0',
            ),
            icon: Icons.play_circle_filled,
            color: Colors.green,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _buildSummaryCard(
            context,
            title: '정차 중',
            value: trackingAsync.when(
              data: (tracking) => tracking.where((t) => !t.isEngineOn).length.toString(),
              loading: () => '...',
              error: (_, __) => '0',
            ),
            icon: Icons.pause_circle_filled,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Icon(icon, size: 32.w, color: color),
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingList(
    BuildContext context,
    List<models.VehicleTracking> trackingList,
    List<models.Vehicle> vehicles,
  ) {
    if (trackingList.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            children: [
              Icon(Icons.location_off, size: 64.w, color: Colors.grey),
              SizedBox(height: 16.h),
              Text(
                '실시간 추적 데이터가 없습니다',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: trackingList.length,
      itemBuilder: (context, index) {
        final tracking = trackingList[index];
        final vehicle = vehicles.firstWhere(
          (v) => v.id == tracking.vehicleId,
          orElse: () => models.Vehicle(
            id: tracking.vehicleId,
            licensePlate: '알 수 없음',
            type: models.VehicleType.bus,
            status: models.VehicleStatus.active,
            make: '',
            model: '',
            year: 2020,
            capacity: 0,
            fuelCapacity: 100,
            currentFuelLevel: 0,
            lastMaintenanceDate: DateTime.now(),
            nextMaintenanceDate: DateTime.now(),
            odometer: 0,
            color: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        return Card(
          margin: EdgeInsets.only(bottom: 12.h),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: tracking.isEngineOn ? Colors.green : Colors.grey,
                      child: Icon(
                        tracking.isEngineOn ? Icons.play_arrow : Icons.pause,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vehicle.licensePlate,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${vehicle.make} ${vehicle.model}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      tracking.isEngineOn ? '운행 중' : '정차',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: tracking.isEngineOn ? Colors.green : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                
                // Location and speed info
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.location_on,
                        title: '위도',
                        value: tracking.currentLocation.latitude.toStringAsFixed(6),
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.location_on,
                        title: '경도',
                        value: tracking.currentLocation.longitude.toStringAsFixed(6),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.speed,
                        title: '속도',
                        value: '${tracking.currentSpeed.toInt()} km/h',
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.local_gas_station,
                        title: '연료',
                        value: '${tracking.fuelLevel.toInt()}%',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16.w, color: Colors.grey),
                    SizedBox(width: 8.w),
                    Text(
                      '최근 업데이트: ${_formatDateTime(tracking.lastUpdate)}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16.w, color: Colors.grey),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget(String message) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          children: [
            Icon(Icons.error, size: 64.w, color: Colors.red),
            SizedBox(height: 16.h),
            Text(
              message,
              style: TextStyle(fontSize: 16.sp, color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Vehicle Management Tab
class VehicleManagementTab extends ConsumerWidget {
  const VehicleManagementTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehiclesProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.refresh(vehiclesProvider);
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '차량 목록',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddVehicleDialog(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('차량 추가'),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            
            vehiclesAsync.when(
              data: (vehicles) => _buildVehicleList(context, ref, vehicles),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildErrorWidget('차량 정보를 불러오는 중 오류가 발생했습니다.'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleList(BuildContext context, WidgetRef ref, List<models.Vehicle> vehicles) {
    if (vehicles.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            children: [
              Icon(Icons.directions_bus_outlined, size: 64.w, color: Colors.grey),
              SizedBox(height: 16.h),
              Text(
                '등록된 차량이 없습니다',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12.h),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: _getVehicleStatusColor(vehicle.status),
                      child: Icon(
                        _getVehicleTypeIcon(vehicle.type),
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vehicle.licensePlate,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${vehicle.make} ${vehicle.model} (${vehicle.year})',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Chip(
                      label: Text(_getVehicleStatusText(vehicle.status)),
                      backgroundColor: _getVehicleStatusColor(vehicle.status).withOpacity(0.1),
                      labelStyle: TextStyle(
                        color: _getVehicleStatusColor(vehicle.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildVehicleInfoItem(
                        icon: Icons.people,
                        title: '정원',
                        value: '${vehicle.capacity}명',
                      ),
                    ),
                    Expanded(
                      child: _buildVehicleInfoItem(
                        icon: Icons.local_gas_station,
                        title: '연료',
                        value: '${vehicle.currentFuelLevel.toInt()}%',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildVehicleInfoItem(
                        icon: Icons.speed,
                        title: '주행거리',
                        value: '${vehicle.odometer.toString().replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (Match m) => '${m[1]},',
                        )}km',
                      ),
                    ),
                    Expanded(
                      child: _buildVehicleInfoItem(
                        icon: Icons.build,
                        title: '다음 정비',
                        value: _formatDate(vehicle.nextMaintenanceDate),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVehicleInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16.w, color: Colors.grey),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddVehicleDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('차량 추가'),
        content: const Text('새 차량을 등록하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _addSampleVehicle(ref);
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  void _addSampleVehicle(WidgetRef ref) async {
    final service = ref.read(vehicleServiceProvider);
    final newVehicle = models.Vehicle(
      id: 'vehicle_${DateTime.now().millisecondsSinceEpoch}',
      licensePlate: '서울${DateTime.now().millisecondsSinceEpoch % 100}가${DateTime.now().millisecondsSinceEpoch % 10000}',
      type: models.VehicleType.van,
      status: models.VehicleStatus.active,
      make: '현대',
      model: '스타렉스',
      year: 2022,
      capacity: 12,
      fuelCapacity: 80.0,
      currentFuelLevel: 85.0,
      lastMaintenanceDate: DateTime.now().subtract(const Duration(days: 20)),
      nextMaintenanceDate: DateTime.now().add(const Duration(days: 70)),
      odometer: 15000,
      color: '검정색',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await service.addVehicle(newVehicle);
    ref.refresh(vehiclesProvider);
  }

  Color _getVehicleStatusColor(models.VehicleStatus status) {
    switch (status) {
      case models.VehicleStatus.active:
        return Colors.green;
      case models.VehicleStatus.inactive:
        return Colors.orange;
      case models.VehicleStatus.maintenance:
        return Colors.blue;
      case models.VehicleStatus.out_of_service:
        return Colors.red;
    }
  }

  String _getVehicleStatusText(models.VehicleStatus status) {
    switch (status) {
      case models.VehicleStatus.active:
        return '운행 중';
      case models.VehicleStatus.inactive:
        return '비활성';
      case models.VehicleStatus.maintenance:
        return '정비 중';
      case models.VehicleStatus.out_of_service:
        return '운행 중단';
    }
  }

  IconData _getVehicleTypeIcon(models.VehicleType type) {
    switch (type) {
      case models.VehicleType.bus:
        return Icons.directions_bus;
      case models.VehicleType.van:
        return Icons.local_shipping;
      case models.VehicleType.car:
        return Icons.directions_car;
      case models.VehicleType.mini_bus:
        return Icons.airport_shuttle;
    }
  }

  Widget _buildErrorWidget(String message) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          children: [
            Icon(Icons.error, size: 64.w, color: Colors.red),
            SizedBox(height: 16.h),
            Text(
              message,
              style: TextStyle(fontSize: 16.sp, color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Route Management Tab
class RouteManagementTab extends ConsumerWidget {
  const RouteManagementTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routesAsync = ref.watch(activeRoutesProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.refresh(activeRoutesProvider);
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '경로 관리',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showCreateRouteDialog(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('경로 생성'),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            
            routesAsync.when(
              data: (routes) => _buildRouteList(context, routes),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildErrorWidget('경로 정보를 불러오는 중 오류가 발생했습니다.'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteList(BuildContext context, List<models.Route> routes) {
    if (routes.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            children: [
              Icon(Icons.route, size: 64.w, color: Colors.grey),
              SizedBox(height: 16.h),
              Text(
                '활성 경로가 없습니다',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: routes.length,
      itemBuilder: (context, index) {
        final route = routes[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12.h),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: _getRouteStatusColor(route.status),
                      child: const Icon(Icons.route, color: Colors.white),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            route.name,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '경유지 ${route.waypoints.length}개',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Chip(
                      label: Text(_getRouteStatusText(route.status)),
                      backgroundColor: _getRouteStatusColor(route.status).withOpacity(0.1),
                      labelStyle: TextStyle(
                        color: _getRouteStatusColor(route.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildRouteInfoItem(
                        icon: Icons.schedule,
                        title: '예상 시간',
                        value: '${route.estimatedDuration}분',
                      ),
                    ),
                    Expanded(
                      child: _buildRouteInfoItem(
                        icon: Icons.straighten,
                        title: '예상 거리',
                        value: '${route.estimatedDistance.toStringAsFixed(1)}km',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildRouteInfoItem(
                        icon: Icons.people,
                        title: '탑승 학생',
                        value: '${route.studentIds.length}명',
                      ),
                    ),
                    Expanded(
                      child: _buildRouteInfoItem(
                        icon: Icons.access_time,
                        title: '시작 시간',
                        value: _formatTime(route.scheduledStartTime),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRouteInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16.w, color: Colors.grey),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCreateRouteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 경로 생성'),
        content: const Text('새로운 경로를 생성하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement route creation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('경로 생성 기능은 곧 추가될 예정입니다.')),
              );
            },
            child: const Text('생성'),
          ),
        ],
      ),
    );
  }

  Color _getRouteStatusColor(models.RouteStatus status) {
    switch (status) {
      case models.RouteStatus.planned:
        return Colors.blue;
      case models.RouteStatus.in_progress:
        return Colors.green;
      case models.RouteStatus.completed:
        return Colors.grey;
      case models.RouteStatus.cancelled:
        return Colors.red;
      case models.RouteStatus.delayed:
        return Colors.orange;
    }
  }

  String _getRouteStatusText(models.RouteStatus status) {
    switch (status) {
      case models.RouteStatus.planned:
        return '계획됨';
      case models.RouteStatus.in_progress:
        return '진행 중';
      case models.RouteStatus.completed:
        return '완료';
      case models.RouteStatus.cancelled:
        return '취소됨';
      case models.RouteStatus.delayed:
        return '지연됨';
    }
  }

  Widget _buildErrorWidget(String message) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          children: [
            Icon(Icons.error, size: 64.w, color: Colors.red),
            SizedBox(height: 16.h),
            Text(
              message,
              style: TextStyle(fontSize: 16.sp, color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Alerts Tab
class AlertsTab extends ConsumerWidget {
  const AlertsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(vehicleAlertsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.refresh(vehicleAlertsProvider);
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '차량 알림',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            
            alertsAsync.when(
              data: (alerts) => _buildAlertsList(context, ref, alerts),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildErrorWidget('알림 정보를 불러오는 중 오류가 발생했습니다.'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsList(BuildContext context, WidgetRef ref, List<models.VehicleAlert> alerts) {
    if (alerts.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            children: [
              Icon(Icons.notifications_none, size: 64.w, color: Colors.grey),
              SizedBox(height: 16.h),
              Text(
                '새로운 알림이 없습니다',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12.h),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: _getAlertSeverityColor(alert.severity),
                      child: Icon(
                        _getAlertTypeIcon(alert.type),
                        color: Colors.white,
                        size: 20.w,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alert.title,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            alert.description,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!alert.isResolved)
                      IconButton(
                        onPressed: () => _resolveAlert(context, ref, alert),
                        icon: const Icon(Icons.check_circle),
                        color: Colors.green,
                      ),
                  ],
                ),
                SizedBox(height: 12.h),
                
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16.w, color: Colors.grey),
                    SizedBox(width: 8.w),
                    Text(
                      _formatDateTime(alert.createdAt),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    Chip(
                      label: Text(alert.isResolved ? '해결됨' : alert.severity.toUpperCase()),
                      backgroundColor: alert.isResolved 
                        ? Colors.green.withOpacity(0.1)
                        : _getAlertSeverityColor(alert.severity).withOpacity(0.1),
                      labelStyle: TextStyle(
                        color: alert.isResolved 
                          ? Colors.green
                          : _getAlertSeverityColor(alert.severity),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _resolveAlert(BuildContext context, WidgetRef ref, models.VehicleAlert alert) async {
    final service = ref.read(vehicleServiceProvider);
    await service.resolveAlert(alert.id, 'user');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('알림이 해결로 표시되었습니다.')),
    );
  }

  Color _getAlertSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
        return Colors.blue;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      case 'critical':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getAlertTypeIcon(models.AlertType type) {
    switch (type) {
      case models.AlertType.speeding:
        return Icons.speed;
      case models.AlertType.geofence_exit:
      case models.AlertType.geofence_enter:
        return Icons.location_on;
      case models.AlertType.maintenance_due:
        return Icons.build;
      case models.AlertType.fuel_low:
        return Icons.local_gas_station;
      case models.AlertType.route_deviation:
        return Icons.wrong_location;
      case models.AlertType.emergency:
        return Icons.emergency;
    }
  }

  Widget _buildErrorWidget(String message) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          children: [
            Icon(Icons.error, size: 64.w, color: Colors.red),
            SizedBox(height: 16.h),
            Text(
              message,
              style: TextStyle(fontSize: 16.sp, color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Helper functions
String _formatDateTime(DateTime dateTime) {
  return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
}

String _formatDate(DateTime dateTime) {
  return '${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
}

String _formatTime(DateTime dateTime) {
  return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
}