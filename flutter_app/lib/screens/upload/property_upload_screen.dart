import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:super_tooltip/super_tooltip.dart';
import '../../models/property.dart';
import '../../models/scene.dart';
import '../../services/property_service.dart';
import '../../services/scene_service.dart';
import '../../config/app_theme.dart';
import 'widgets/scene_upload_card.dart';
import 'widgets/info_tooltip.dart';
import 'widgets/hotspot_editor.dart';

/// Property Upload Screen - PRIORITY 1
/// Seller page to upload properties with 360° images
/// Includes tooltips, hints, and guided help
class PropertyUploadScreen extends StatefulWidget {
  const PropertyUploadScreen({Key? key}) : super(key: key);

  @override
  State<PropertyUploadScreen> createState() => _PropertyUploadScreenState();
}

class _PropertyUploadScreenState extends State<PropertyUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final PropertyService _propertyService = PropertyService();
  final SceneService _sceneService = SceneService();
  final ImagePicker _imagePicker = ImagePicker();

  // Tutorial coach marks
  late TutorialCoachMark tutorialCoachMark;
  final List<TargetFocus> targets = [];

  // Form controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _bedroomsController = TextEditingController();
  final TextEditingController _bathroomsController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();

  // Form state
  PropertyType _propertyType = PropertyType.buy;
  bool _furnished = false;
  List<String> _tags = [];
  final List<File> _propertyImages = [];
  
  // 360 Tour scenes
  final List<SceneUploadData> _scenes = [];
  
  // Hotspots for each scene
  final Map<String, List<HotspotModel>> _sceneHotspots = {};

  bool _isLoading = false;
  int _currentStep = 0;

  // Keys for tooltip targets
  final GlobalKey _titleKey = GlobalKey();
  final GlobalKey _priceKey = GlobalKey();
  final GlobalKey _tourKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Show tutorial on first launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showTutorial();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _sizeController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    _propertyService.dispose();
    _sceneService.dispose();
    super.dispose();
  }

  void _showTutorial() {
    targets.clear();
    
    targets.add(
      TargetFocus(
        identify: "title",
        keyTarget: _titleKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Property Title",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Enter an attractive title for your property. Be descriptive!",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "tour",
        keyTarget: _tourKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "360° Virtual Tour",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Upload 360° panoramic images for each room. Click arrows to add navigation between rooms!",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: AppTheme.primaryColor,
      paddingFocus: 10,
      opacityShadow: 0.8,
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        tutorialCoachMark.show(context: context);
      }
    });
  }

  Future<void> _pickPropertyImages() async {
    final List<XFile> images = await _imagePicker.pickMultiImage();
    setState(() {
      _propertyImages.addAll(images.map((xfile) => File(xfile.path)));
    });
  }

  void _addScene() {
    setState(() {
      _scenes.add(SceneUploadData(
        name: 'Room ${_scenes.length + 1}',
        order: _scenes.length,
      ));
    });
  }

  void _removeScene(int index) {
    setState(() {
      _scenes.removeAt(index);
      // Reorder remaining scenes
      for (int i = 0; i < _scenes.length; i++) {
        _scenes[i].order = i;
      }
    });
  }

  Future<void> _submitProperty() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_scenes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one 360° scene'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Step 1: Create property
      final property = await _propertyService.createProperty(
        title: _titleController.text,
        description: _descriptionController.text,
        propertyType: _propertyType,
        price: double.parse(_priceController.text),
        sizeSqft: _sizeController.text.isNotEmpty ? double.parse(_sizeController.text) : null,
        bedrooms: _bedroomsController.text.isNotEmpty ? int.parse(_bedroomsController.text) : null,
        bathrooms: _bathroomsController.text.isNotEmpty ? int.parse(_bathroomsController.text) : null,
        furnished: _furnished,
        addressLine: _addressController.text,
        city: _cityController.text,
        state: _stateController.text.isNotEmpty ? _stateController.text : null,
        country: _countryController.text,
        postalCode: _postalCodeController.text.isNotEmpty ? _postalCodeController.text : null,
        tags: _tags.isNotEmpty ? _tags : null,
      );

      // Step 2: Upload scenes
      for (final sceneData in _scenes) {
        if (sceneData.images.isNotEmpty) {
          await _sceneService.createScene(
            propertyId: property.id,
            sceneName: sceneData.name,
            sceneOrder: sceneData.order,
            images: sceneData.images,
          );
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Property uploaded successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Property'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showTutorial,
            tooltip: 'Show Tutorial',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: _currentStep < 3
              ? () => setState(() => _currentStep++)
              : null,
          onStepCancel: _currentStep > 0
              ? () => setState(() => _currentStep--)
              : null,
          steps: [
            Step(
              title: const Text('Basic Information'),
              content: _buildBasicInfoStep(),
              isActive: _currentStep >= 0,
            ),
            Step(
              title: const Text('360° Virtual Tour'),
              content: _build360TourStep(),
              isActive: _currentStep >= 1,
            ),
            Step(
              title: const Text('Add Hotspots'),
              content: _buildHotspotsStep(),
              isActive: _currentStep >= 2,
            ),
            Step(
              title: const Text('Review & Submit'),
              content: _buildReviewStep(),
              isActive: _currentStep >= 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InfoTooltip(
          message: 'Enter a catchy title that describes your property well',
          child: TextFormField(
            key: _titleKey,
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Property Title *',
              hintText: 'e.g., Modern 3BR Apartment in Downtown',
              prefixIcon: Icon(Icons.title),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a title';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        
        InfoTooltip(
          message: 'Provide detailed description about the property features and amenities',
          child: TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Describe your property...',
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 4,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),

        Row(
          children: [
            Expanded(
              child: InfoTooltip(
                message: 'Select whether this property is for sale or rent',
                child: DropdownButtonFormField<PropertyType>(
                  value: _propertyType,
                  decoration: const InputDecoration(
                    labelText: 'Type *',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: PropertyType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _propertyType = value!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: InfoTooltip(
                message: 'Enter the price in USD',
                child: TextFormField(
                  key: _priceKey,
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price (USD) *',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter price';
                    }
                    return null;
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingM),

        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _bedroomsController,
                decoration: const InputDecoration(
                  labelText: 'Bedrooms',
                  prefixIcon: Icon(Icons.bed),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: TextFormField(
                controller: _bathroomsController,
                decoration: const InputDecoration(
                  labelText: 'Bathrooms',
                  prefixIcon: Icon(Icons.bathtub),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: TextFormField(
                controller: _sizeController,
                decoration: const InputDecoration(
                  labelText: 'Size (sqft)',
                  prefixIcon: Icon(Icons.square_foot),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingM),

        SwitchListTile(
          title: const Text('Furnished'),
          subtitle: const Text('Is this property furnished?'),
          value: _furnished,
          onChanged: (value) {
            setState(() {
              _furnished = value;
            });
          },
        ),
        const SizedBox(height: AppTheme.spacingM),

        Text(
          'Address',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppTheme.spacingS),
        
        TextFormField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: 'Street Address *',
            prefixIcon: Icon(Icons.home),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter address';
            }
            return null;
          },
        ),
        const SizedBox(height: AppTheme.spacingM),

        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City *',
                  prefixIcon: Icon(Icons.location_city),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(
                  labelText: 'State/Province',
                  prefixIcon: Icon(Icons.map),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingM),

        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _countryController,
                decoration: const InputDecoration(
                  labelText: 'Country *',
                  prefixIcon: Icon(Icons.flag),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: TextFormField(
                controller: _postalCodeController,
                decoration: const InputDecoration(
                  labelText: 'Postal Code',
                  prefixIcon: Icon(Icons.local_post_office),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _build360TourStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          key: _tourKey,
          padding: const EdgeInsets.all(AppTheme.spacingM),
          decoration: BoxDecoration(
            color: AppTheme.infoColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            border: Border.all(color: AppTheme.infoColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppTheme.infoColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '360° Tour Instructions',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.infoColor,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Upload panoramic 360° images for each room. Buyers can navigate between rooms using interactive arrows!',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacingL),

        ..._scenes.asMap().entries.map((entry) {
          final index = entry.key;
          final scene = entry.value;
          return SceneUploadCard(
            scene: scene,
            index: index,
            totalScenes: _scenes.length,
            onRemove: () => _removeScene(index),
            onUpdate: (updatedScene) {
              setState(() {
                _scenes[index] = updatedScene;
              });
            },
          );
        }),

        const SizedBox(height: AppTheme.spacingM),

        OutlinedButton.icon(
          onPressed: _addScene,
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Add Another Room/Scene'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      ],
    );
  }

  Widget _buildHotspotsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF667EEA).withOpacity(0.1),
                const Color(0xFF764BA2).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: const Border(
              left: BorderSide(color: Color(0xFF667EEA), width: 4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🎯 Connect Your Rooms',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF667EEA),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add navigation arrows on doors and passages so visitors can walk through your property naturally. '
                'This creates an immersive experience where tapping on a door takes you to the next room!',
                style: TextStyle(
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Show hotspot editors for each scene
        if (_scenes.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                children: [
                  const Text(
                    '📸 Please add rooms in the previous step before adding hotspots.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() => _currentStep = 1),
                    child: const Text('← Go Back to Add Rooms'),
                  ),
                ],
              ),
            ),
          )
        else
          ..._scenes.map((sceneData) {
            final sceneId = sceneData.name; // Use scene name as temporary ID
            return HotspotEditor(
              scene: Scene(
                id: sceneId,
                name: sceneData.name,
                imagePaths: sceneData.images.map((f) => f.path).toList(),
                sceneOrder: _scenes.indexOf(sceneData),
              ),
              allScenes: _scenes.map((s) {
                return Scene(
                  id: s.name,
                  name: s.name,
                  imagePaths: s.images.map((f) => f.path).toList(),
                  sceneOrder: _scenes.indexOf(s),
                );
              }).toList(),
              onHotspotsChanged: (hotspots) {
                setState(() {
                  _sceneHotspots[sceneId] = hotspots;
                });
              },
            );
          }).toList(),

        if (_scenes.length < 2)
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(8),
              border: const Border(
                left: BorderSide(color: Colors.amber, width: 4),
              ),
            ),
            child: const Text(
              '💡 Tip: You need at least 2 rooms to create navigation hotspots between them. '
              'Add more rooms in the previous step!',
              style: TextStyle(color: Color(0xFF92400E)),
            ),
          ),
      ],
    );
  }

  Widget _buildReviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review Your Property',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppTheme.spacingM),
        
        _buildReviewItem('Title', _titleController.text),
        _buildReviewItem('Type', _propertyType.displayName),
        _buildReviewItem('Price', '\$${_priceController.text}'),
        _buildReviewItem('Address', _addressController.text),
        _buildReviewItem('City', _cityController.text),
        _buildReviewItem('360° Scenes', '${_scenes.length} rooms'),
        
        // Show details for each scene
        if (_scenes.isNotEmpty)
          ..._scenes.map((scene) {
            final sceneId = scene.name;
            final hotspotCount = _sceneHotspots[sceneId]?.length ?? 0;
            return Padding(
              padding: const EdgeInsets.only(left: 16, top: 8),
              child: Text(
                '→ ${scene.name}: ${scene.images.length} image(s), $hotspotCount hotspot(s)',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            );
          }).toList(),
        
        const SizedBox(height: AppTheme.spacingL),

        ElevatedButton.icon(
          onPressed: _isLoading ? null : _submitProperty,
          icon: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.cloud_upload),
          label: Text(_isLoading ? 'Uploading...' : 'Submit Property'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            backgroundColor: AppTheme.successColor,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'Not provided',
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Scene upload data model
class SceneUploadData {
  String name;
  int order;
  List<File> images;

  SceneUploadData({
    required this.name,
    required this.order,
    this.images = const [],
  });
}

