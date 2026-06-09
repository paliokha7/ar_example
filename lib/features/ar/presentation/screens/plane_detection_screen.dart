import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../cubit/plane_detection_cubit.dart';
import '../cubit/plane_detection_state.dart';
import '../widgets/unified_ar_view.dart';
import '../widgets/ar_controls.dart';

class PlaneDetectionScreen extends StatefulWidget {
  const PlaneDetectionScreen({super.key});

  @override
  State<PlaneDetectionScreen> createState() => _PlaneDetectionScreenState();
}

class _PlaneDetectionScreenState extends State<PlaneDetectionScreen> {
  late final PlaneDetectionCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<PlaneDetectionCubit>();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Plane Detection'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/ar-examples');
              }
            },
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
        extendBodyBehindAppBar: true,
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<PlaneDetectionCubit, PlaneDetectionState>(
      bloc: _cubit,
      builder: (context, state) {
        return Stack(
          children: [
            UnifiedARView(
              onViewCreated: (viewId) {
                _cubit.initializeAR(viewId);
              },
            ),
            if (state is PlaneDetectionLoading)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'Initializing AR...',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            if (state is PlaneDetectionError)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Card(
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'AR Error',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _cubit.resetSession(),
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ARControls(
              state: state,
              onPlaceChair: () => _cubit.placeChair(),
              onRemoveChair: () => _cubit.removeChair(),
              onReset: () => _cubit.resetSession(),
            ),
          ],
        );
      },
    );
  }
}