import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const ConstructionEnterpriseApp());
}

class ConstructionEnterpriseApp extends StatelessWidget {
  const ConstructionEnterpriseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vertex Enterprise',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF2B705), 
          primary: const Color(0xFFF2B705),
          secondary: const Color(0xFF1E293B), 
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      home: const EnterpriseSplashScreen(),
    );
  }
}

class EnterpriseSplashScreen extends StatefulWidget {
  const EnterpriseSplashScreen({super.key});

  @override
  State<EnterpriseSplashScreen> createState() => _EnterpriseSplashScreenState();
}

class _EnterpriseSplashScreenState extends State<EnterpriseSplashScreen> {
  String statusText = "Initializing secure data networks...";

  @override
  void initState() {
    super.initState();
    _executeSystemBootSequence();
  }

  Future<void> _executeSystemBootSequence() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() { statusText = "Verifying cloud registry structures..."; });
    
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() { statusText = "Establishing live database synchronization..."; });
    
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainEnterpriseDashboard()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E293B),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF2B705),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: const Color(0xFFF2B705).withOpacity(0.2), blurRadius: 20, spreadRadius: 5)
                ],
              ),
              child: const Icon(Icons.token, color: Color(0xFF1E293B), size: 64),
            ),
            const SizedBox(height: 25),
            const Text(
              'VERTEX ENTERPRISE',
              style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 24, letterSpacing: 2.0),
            ),
            const SizedBox(height: 6),
            Text(
              'CONSTRUCTION & ENGINEERING SYSTEMS',
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
            ),
            const SizedBox(height: 50),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: Color(0xFFF2B705), strokeWidth: 2.5),
            ),
            const SizedBox(height: 20),
            Text(statusText, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12, fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }
}
class MainEnterpriseDashboard extends StatefulWidget {
  const MainEnterpriseDashboard({super.key});

  @override
  State<MainEnterpriseDashboard> createState() => _MainEnterpriseDashboardState();
}

class _MainEnterpriseDashboardState extends State<MainEnterpriseDashboard> {
  final String apiEndpoint = "https://vertex-construction-api.onrender.com";
  List projects = [];
  bool isLoading = true;
  bool hasError = false;
  int _activeTabIndex = 0;

  bool _isShowingEmergencyBanner = false;
  String _alertForemanName = "";
  String _alertDetails = "";

  String _selectedMapNode = "Lagos";
  String _mapProjectName = "Eko Atlantic High-Rise Base";
  String _mapBudget = "₦15,000,000.00";
  String _mapCoordinates = "6.4281° N, 3.4219° E";

  final _projectFormKey = GlobalKey<FormState>();
  final _projectNameController = TextEditingController();
  final _projectLocationController = TextEditingController();
  final _projectBudgetController = TextEditingController();

  final _ticketFormKey = GlobalKey<FormState>();
  final _foremanController = TextEditingController();
  final _detailsController = TextEditingController();
  String _selectedPriority = 'Low';

  @override
  void initState() {
    super.initState();
    fetchActiveProjects();
  }

  Future<void> fetchActiveProjects() async {
    setState(() { isLoading = true; hasError = false; });
    try {
      final response = await http.get(Uri.parse(apiEndpoint)).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        setState(() {
          projects = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() { isLoading = false; hasError = true; });
      }
    } catch (e) {
      setState(() { isLoading = false; hasError = true; });
    }
  }

  Future<void> addNewProjectToCloud() async {
    if (!_projectFormKey.currentState!.validate()) return;

    final String cleanName = _projectNameController.text.trim();
    final String cleanLocation = _projectLocationController.text.trim();
    final String cleanBudget = _projectBudgetController.text.trim();

    try {
      final response = await http.post(
        Uri.parse(apiEndpoint),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "name": cleanName,
          "location": cleanLocation,
          "budget": cleanBudget,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 201 || response.statusCode == 200) {
        _projectNameController.clear();
        _projectLocationController.clear();
        _projectBudgetController.clear();
        FocusScope.of(context).unfocus(); 
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 New Infrastructure Asset Tracked Successfully!'), backgroundColor: Colors.green),
        );
        fetchActiveProjects(); 
      }
    } catch (e) {
      FocusScope.of(context).unfocus();
      fetchActiveProjects();
    }
  }

  void _submitSupportTicket() {
    if (_ticketFormKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      
      final String inputName = _foremanController.text.trim();
      final String inputDetails = _detailsController.text.trim();

      if (_selectedPriority == 'High / Critical') {
        setState(() {
          _isShowingEmergencyBanner = true;
          _alertForemanName = inputName;
          _alertDetails = inputDetails;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('📡 Support log recorded successfully (Priority: $_selectedPriority)')),
        );
      }
      
      _foremanController.clear();
      _detailsController.clear();
    }
  }

  void _updateMapTelemetry(String node, String project, String budget, String geo) {
    setState(() {
      _selectedMapNode = node;
      _mapProjectName = project;
      _mapBudget = budget;
      _mapCoordinates = geo;
    });
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: const Color(0xFF1E293B), 
        elevation: 4,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFFF2B705), borderRadius: BorderRadius.circular(6)),
              child: const Icon(Icons.token, color: Color(0xFF1E293B), size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('VERTEX ENTERPRISE', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 14, letterSpacing: 1.1)),
                Text('CONSTRUCTION SYSTEMS', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: fetchActiveProjects),
          const SizedBox(width: 10),
        ],
      ),
      bottomNavigationBar: !isDesktop ? BottomNavigationBar(
        currentIndex: _activeTabIndex,
        onTap: (index) => setState(() => _activeTabIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analytics'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Reports'),
        ],
      ) : null,
      body: Stack(
        children: [
          _buildSelectedTabScreen(isDesktop),
          if (_isShowingEmergencyBanner)
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.redAccent,
                child: SafeArea(
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('🚨 CRITICAL FIELD EMERGENCY: $_alertForemanName', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 2),
                            Text(_alertDetails, style: const TextStyle(color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => setState(() => _isShowingEmergencyBanner = false),
                      )
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedTabScreen(bool isDesktop) {
    switch (_activeTabIndex) {
      case 1:
        return _buildAnalyticsSection();
      case 2:
        return _buildReportsSection();
      default:
        return _buildMainDashboardContent(isDesktop);
    }
  }

  Widget _buildMainDashboardContent(bool isDesktop) {
    return RefreshIndicator(
      color: const Color(0xFFF2B705),
      backgroundColor: const Color(0xFF1E293B),
      onRefresh: fetchActiveProjects, 
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(25),
              width: double.infinity,
              color: const Color(0xFF1E293B),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFF2B705), borderRadius: BorderRadius.circular(4)),
                    child: const Text('GLOBAL MOBILE LINK', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF1E293B))),
                  ),
                  const SizedBox(height: 10),
                  const Text('Operational Room', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text('Live capital distributions and structural data analytics.', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildProjectSection(),
                  const SizedBox(height: 25),
                  _buildInteractiveMapWidget(), 
                  const SizedBox(height: 30),
                  _buildAdminInputFormSection(), 
                  const SizedBox(height: 30),
                  _buildSupportFormSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildProjectSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Active Infrastructure Sites', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        const SizedBox(height: 15),
        if (isLoading)
          const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
        else if (hasError)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.cloud_off, size: 40, color: Colors.grey),
                  const SizedBox(height: 8),
                  const Text('Syncing with online database...', style: TextStyle(color: Colors.grey)),
                  TextButton(onPressed: fetchActiveProjects, child: const Text('Retry Connection'))
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/construction_hero.jpg', 
                        height: 140, 
                        width: double.infinity, 
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 140,
                            color: const Color(0xFF1E293B).withOpacity(0.05),
                            child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
                          );
                        },
                      ),
                      ListTile(
                        contentPadding: const EdgeInsets.all(15),
                        title: Text(project['name'] ?? 'Active Operation', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [const Icon(Icons.location_on, size: 14, color: Colors.grey), const SizedBox(width: 6), Expanded(child: Text(project['location'] ?? 'N/A', style: const TextStyle(fontSize: 13)))]),
                              const SizedBox(height: 6),
                              Row(children: [const Icon(Icons.payments, size: 14, color: Colors.green), const SizedBox(width: 6), Text('Budget: ₦${project['budget'] ?? '0.00'}', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.green, fontSize: 13))]),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildInteractiveMapWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Geographic Site Telemetry', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMapPinBtn("Lagos", "Eko Atlantic Base", "₦15.0M", "6.4281° N, 3.4219° E"),
              _buildMapPinBtn("Abuja", "Airport Extension", "₦4.5M", "9.0064° N, 7.2631° E"),
              _buildMapPinBtn("P.H.", "Refinery Upgrade", "₦8.2M", "4.7431° N, 7.1142° E"),
              _buildMapPinBtn("Kano", "Rail Terminal Log", "₦3.5M", "12.0022° N, 8.5919° E"),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ZONE: $_selectedMapNode NIGERIA', style: const TextStyle(color: Color(0xFFF2B705), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.0)),
                    const Icon(Icons.radar, color: Colors.greenAccent, size: 16),
                  ],
                ),
                const SizedBox(height: 10),
                Text(_mapProjectName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.gps_fixed, color: Colors.grey, size: 14),
                    const SizedBox(width: 6),
                    Text(_mapCoordinates, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                    const Spacer(),
                    const Icon(Icons.payments, color: Colors.greenAccent, size: 14),
                    const SizedBox(width: 6),
                    Text(_mapBudget, style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMapPinBtn(String title, String proj, String budget, String geo) {
    bool isSelected = _selectedMapNode == title;
    return ElevatedButton(
      onPressed: () => _updateMapTelemetry(title, proj, budget, geo),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFFF2B705) : const Color(0xFFF8FAFC),
        foregroundColor: isSelected ? const Color(0xFF1E293B) : Colors.grey,
        elevation: isSelected ? 3 : 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
  Widget _buildAdminInputFormSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF2B705).withOpacity(0.3), width: 1),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      child: Form(
        key: _projectFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.add_business, color: Color(0xFFF2B705)),
                SizedBox(width: 10),
                Text('Project Registry Provisioning', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              ],
            ),
            const SizedBox(height: 6),
            const Text('Provision new structural assets and capital budgets directly into cloud arrays.', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 20),
            TextFormField(
              controller: _projectNameController,
              decoration: const InputDecoration(labelText: 'Project / Asset Title', border: OutlineInputBorder(), prefixIcon: Icon(Icons.business)),
              validator: (v) => v!.isEmpty ? 'Enter asset title descriptive string' : null,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _projectLocationController,
              decoration: const InputDecoration(labelText: 'Site Geographic Location', border: OutlineInputBorder(), prefixIcon: Icon(Icons.pin_drop)),
              validator: (v) => v!.isEmpty ? 'Enter structural site coordinates' : null,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _projectBudgetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Budget Capital Allocation (₦)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.monetization_on)),
              validator: (v) => v!.isEmpty ? 'Specify investment numeric string value' : null,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: addNewProjectToCloud,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF2B705), foregroundColor: const Color(0xFF1E293B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: const Text('TRANSMIT NEW ASSET TO CLOUD', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5, fontSize: 13)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSupportFormSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Form(
        key: _ticketFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Field Support & Incidents', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const SizedBox(height: 20),
            TextFormField(
              controller: _foremanController,
              decoration: const InputDecoration(labelText: 'Foreman Name', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
              validator: (v) => v!.isEmpty ? 'Enter manager name' : null,
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              decoration: const InputDecoration(labelText: 'Urgency Priority', border: OutlineInputBorder(), prefixIcon: Icon(Icons.warning)),
              items: ['Low', 'Medium', 'High / Critical'].map((String val) { return DropdownMenuItem<String>(value: val, child: Text(val)); }).toList(),
              onChanged: (v) => setState(() => _selectedPriority = v!),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _detailsController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Log Event Details', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? 'Describe the site issue' : null,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _submitSupportTicket,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: const Text('TRANSMIT REPORT TO BASE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5, fontSize: 13)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsSection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('📈 Enterprise Financial Metrics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        const SizedBox(height: 25),
        Row(children: [
          _buildStatCard('Total Projects Active', '${projects.length}', Icons.architecture, Colors.blue),
          const SizedBox(width: 15),
          _buildStatCard('Gross Structural Allocations', '₦27.7M', Icons.account_balance_wallet, Colors.green),
        ])
      ]),
    );
  }

  Widget _buildStatCard(String title, String val, IconData icon, Color col) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)]),
        child: Row(children: [
          CircleAvatar(radius: 18, backgroundColor: col.withOpacity(0.1), child: Icon(icon, color: col, size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(val, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          ]))
        ]),
      ),
    );
  }

  Widget _buildReportsSection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('📋 Daily Verification Logs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        const SizedBox(height: 25),
        Container(
          width: double.infinity, padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: const ListTile(
            leading: Icon(Icons.verified_user, color: Colors.green, size: 26),
            title: Text('Structural Integrity Audit - Active Pass', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Padding(padding: EdgeInsets.only(top: 4.0), child: Text('Site Location: Victoria Island, Lagos • Status: Verified', style: TextStyle(fontSize: 12))),
          ),
        )
      ]),
    );
  }
}
