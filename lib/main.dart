import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:open_file/open_file.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common/sqlite_api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  final Database db =
      await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);

  runApp(MyApp(db));
}

class MyApp extends StatelessWidget {
  final Database database;
  MyApp(this.database);
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double paddingValue = screenWidth * 0.05;
    return Padding(
        padding: EdgeInsets.all(paddingValue),
        child: MaterialApp(
          theme: customLightTheme(),
          home: LoginPage(),
        ));
  }
}

enum UserRole { admin, user }

ThemeData customLightTheme() {
  final ThemeData lightTheme = ThemeData.light();
  return lightTheme.copyWith(
    primaryColor: Color.fromARGB(255, 250, 200, 216),
    indicatorColor: Color.fromARGB(255, 233, 123, 160),
    scaffoldBackgroundColor: Color.fromARGB(255, 250, 200, 216),
    hoverColor: Color.fromARGB(255, 250, 200, 216),
    cardColor: Color.fromARGB(255, 233, 123, 160),
    appBarTheme: lightTheme.appBarTheme.copyWith(
      backgroundColor: Color.fromARGB(255, 233, 123, 160),
    ),
  );
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              // Add your onTap action here
            },
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background_image.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: LoginForm(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  'assets/background_image.jpg'), // Ganti dengan gambar latar belakang yang sesuai
              fit: BoxFit.cover,
            ),
          ),
        ),
        Center(
          child: LoginForm(),
        ),
      ],
    ),
  );
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String errorMessage = '';
  DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<void> _validateLogin(BuildContext context) async {
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    await _databaseHelper._initDatabase();

    var validationResult =
        await _databaseHelper.validateUser(username, password);

    if (validationResult?['isValid'] ?? false) {
      UserRole userRole =
          validationResult!['role'] == 'admin' ? UserRole.admin : UserRole.user;

      print('Obtained UserRole: $userRole');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(userRole: userRole),
        ),
      );
    } else {
      setState(() {
        errorMessage = 'Username atau password salah';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: usernameController,
            style: TextStyle(color: Color.fromARGB(255, 233, 123, 160)),
            decoration: InputDecoration(
              labelText: 'Username',
              filled: true,
              fillColor: Colors.white,
              labelStyle: TextStyle(color: Color.fromARGB(255, 233, 123, 160)),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Color.fromARGB(255, 233, 123, 160)),
              ),
            ),
          ),
          SizedBox(height: 16.0),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              filled: true,
              fillColor: Colors.white,
              labelStyle: TextStyle(color: Color.fromARGB(255, 233, 123, 160)),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Color.fromARGB(255, 233, 123, 160)),
              ),
            ),
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              _validateLogin(context);
            },
            child: Text('Login'),
            style: ElevatedButton.styleFrom(
              primary: Color.fromARGB(255, 233, 123, 160),
            ),
          ),
          SizedBox(height: 16.0),
          Text(
            errorMessage,
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }
}

class AddUserPage extends StatefulWidget {
  final UserModel? userModel;

  AddUserPage({this.userModel});
  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'admin';

  DatabaseHelper DB = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add User'),
        backgroundColor: Color.fromARGB(
            255, 233, 123, 160), // Sesuaikan dengan warna tema Anda
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  fillColor: Colors.white,
                  labelStyle:
                      TextStyle(color: Color.fromARGB(255, 233, 123, 160)),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 233, 123, 160)),
                  ),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter username';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  fillColor: Colors.white,
                  labelStyle:
                      TextStyle(color: Color.fromARGB(255, 233, 123, 160)),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 233, 123, 160)),
                  ),
                ),
                obscureText: true,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter password';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: InputDecoration(
                  labelText: 'Role',
                  fillColor: Colors.white,
                  labelStyle:
                      TextStyle(color: Color.fromARGB(255, 233, 123, 160)),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 233, 123, 160)),
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    child: Text('Admin'),
                    value: 'admin',
                  ),
                  DropdownMenuItem(
                    child: Text('User'),
                    value: 'user',
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a role';
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final users = UserModel(
                        username: _usernameController.text,
                        password: _passwordController.text,
                        role: _selectedRole,
                      );
                      await DB.insertUser(users);
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Submit'),
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(
                        255, 233, 123, 160), // Sesuaikan dengan warna tema Anda
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final UserRole userRole; // Add this property

  // Add UserRole parameter to the constructor
  HomePage({required this.userRole});

  @override
  Widget build(BuildContext context) {
    print('UserRole: $userRole');
    return Scaffold(
      appBar: AppBar(
        title: Text('Point of Sale'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InfoCard(title: 'Total Transaksi Harian', value: '123'),
          InfoCard(title: 'Total Penjualan Barang Harian', value: '456'),
          InfoCard(title: 'Pembelian Terbesar Harian', value: '789'),
          InfoCard(title: 'Rata-rata Penjualan Harian', value: '321'),
          SizedBox(height: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddTransactionPage()),
                  );
                },
                child: Text('Tambah Transaksi'),
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 233, 123, 160),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 16), // Atur jarak di sini
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddUserPage()),
                    );
                  },
                  child: Text('Tambah User'),
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 233, 123, 160),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _logout(context),
        child: Icon(Icons.logout),
        backgroundColor: Color.fromARGB(255, 233, 123, 160),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniStartDocked,
    );
  }

  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
      (route) => false,
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String value;

  const InfoCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        trailing: Text(
          value,
          textAlign: TextAlign.end,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}

class AddTransactionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Transaksi'),
      ),
      body: AddTransactionForm(),
    );
  }
}

class AddTransactionForm extends StatefulWidget {
  @override
  _AddTransactionFormState createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends State<AddTransactionForm> {
  TextEditingController itemNameController = TextEditingController();
  TextEditingController qtyBarangController = TextEditingController();
  TextEditingController qtyYardController = TextEditingController();
  TextEditingController hargaController = TextEditingController();

  // List to store transactions in the cart
  List<String> cartItems = [];
  String dropdownValue = 'Katun';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          DropdownButton<String>(
            // Implement dropdown logic here
            value: dropdownValue,
            onChanged: (String? newValue) {
              setState(() {
                dropdownValue = newValue!;
              });
            },
            items: <String>['Katun', 'Sutra', 'Wol', 'Flanel']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            hint: Text('Pilih Nama Barang'),
            style: TextStyle(color: Color.fromARGB(255, 233, 123, 160)),
          ),
          TextField(
            controller: qtyBarangController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: Color.fromARGB(255, 233, 123, 160)),
            decoration: InputDecoration(
              labelText: 'Qty Barang',
              labelStyle: TextStyle(color: Color.fromARGB(255, 233, 123, 160)),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Color.fromARGB(255, 233, 123, 160)),
              ),
            ),
          ),
          TextField(
            controller: qtyYardController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: Color.fromARGB(255, 233, 123, 160)),
            decoration: InputDecoration(
              labelText: 'Qty Yard',
              labelStyle: TextStyle(color: Color.fromARGB(255, 233, 123, 160)),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Color.fromARGB(255, 233, 123, 160)),
              ),
            ),
          ),
          TextField(
            controller: hargaController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: Color.fromARGB(255, 233, 123, 160)),
            decoration: InputDecoration(
              labelText: 'Harga',
              labelStyle: TextStyle(color: Color.fromARGB(255, 233, 123, 160)),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Color.fromARGB(255, 233, 123, 160)),
              ),
            ),
          ),
          SizedBox(height: 16.0),
          FloatingActionButton(
            onPressed: () {
              // Implement add to cart logic here
              addToCart();
            },
            backgroundColor: Color.fromARGB(255, 233, 123, 160),
            child: Icon(Icons.add),
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              // Navigate to the page displaying transactions in the cart
              navigateToCartPage(context);
            },
            style: ElevatedButton.styleFrom(
              primary: Color.fromARGB(255, 233, 123, 160), // Set warna tombol
            ),
            child: Text('Lihat Cart'),
          ),
        ],
      ),
    );
  }

  void addToCart() {
    // Implement logic to add transaction to cart
    // For example, you can add the transaction details to the cartItems list
    String transactionDetails =
        'Item: ${dropdownValue}, Qty: ${qtyBarangController.text}, Yard: ${qtyYardController.text}, Harga: ${hargaController.text}';
    cartItems.add(transactionDetails);

    // Clear input fields after adding to cart
    itemNameController.clear();
    qtyBarangController.clear();
    qtyYardController.clear();
    hargaController.clear();
  }

  void navigateToCartPage(BuildContext context) {
    // Navigate to the page displaying transactions in the cart
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartPage(cartItems: cartItems),
      ),
    );
  }
}

class CartPage extends StatefulWidget {
  final List<String> cartItems;

  CartPage({required this.cartItems});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  String selectedPaymentMethod = 'Cash';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            DataTable(
              columns: [
                DataColumn(label: Text('Item')),
                DataColumn(label: Text('Qty')),
                DataColumn(label: Text('Yard')),
                DataColumn(label: Text('Harga')),
              ],
              rows: widget.cartItems.map((transactionDetails) {
                List<String> details = transactionDetails.split(', ');
                return DataRow(
                  cells: [
                    DataCell(Text(details[0])),
                    DataCell(Text(details[1])),
                    DataCell(Text(details[2])),
                    DataCell(Text(details[3])),
                  ],
                );
              }).toList(),
            ),
            SizedBox(height: 16.0),
            _buildPaymentMethodDropdown(),
            SizedBox(height: 16.0),
            (_buildPrintButton(context)), // Ensure this line is present
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodDropdown() {
    return DropdownButton<String>(
      value: selectedPaymentMethod,
      onChanged: (value) {
        setState(() {
          selectedPaymentMethod = value!;
        });
      },
      items: ['Cash', 'Transfer']
          .map((method) => DropdownMenuItem<String>(
                value: method,
                child: Text(method),
              ))
          .toList(),
      hint: Text('Pilih Metode Pembayaran'),
    );
  }

  Widget _buildPrintButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        _printTransactionsToPDF(context);
      },
      style: ElevatedButton.styleFrom(
        primary: Color.fromARGB(255, 233, 123, 160), // Set warna tombol
      ),
      child: Text('Print to PDF'),
    );
  }

  void _printTransactionsToPDF(BuildContext context) async {
    // Create a PDF document
    final pdf = pdfLib.Document();

    // Add a page to the document
    pdf.addPage(
      pdfLib.Page(
        build: (context) => pdfLib.Column(
          children: [
            pdfLib.Text('Detail Transaksi',
                style: pdfLib.TextStyle(fontSize: 20)),
            pdfLib.SizedBox(height: 16),
            pdfLib.Table(
              children: [
                // Header row
                pdfLib.TableRow(
                  children: [
                    pdfLib.Text('Item'),
                    pdfLib.Text('Qty'),
                    pdfLib.Text('Yard'),
                    pdfLib.Text('Harga'),
                  ],
                ),
                // Data rows
                for (var transactionDetails in widget.cartItems)
                  pdfLib.TableRow(
                    children: transactionDetails
                        .split(', ')
                        .map((detail) => pdfLib.Text(detail))
                        .toList(),
                  ),
              ],
            ),
            pdfLib.SizedBox(height: 16),
            pdfLib.Text('Metode Pembayaran: $selectedPaymentMethod',
                style: pdfLib.TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );

    // Save the PDF to a file
    final output = await getTemporaryDirectory();
    final file = io.File("${output.path}/transaksi.pdf");
    await file.writeAsBytes(await pdf.save());

    // Open the PDF
    OpenFile.open(file.path);

    // Navigate back to the main page after printing
    Navigator.pop(context);
  }
}

class BarangModel {
  final int idBarang;
  final String namaBarang;
  final int harga;
  final int stock;

  BarangModel({
    required this.idBarang,
    required this.namaBarang,
    required this.harga,
    required this.stock,
  });

  factory BarangModel.fromMap(Map<String, dynamic> json) => BarangModel(
        idBarang: json["IdBarang"],
        namaBarang: json["NamaBarang"],
        harga: json["Harga"],
        stock: json["Stock"],
      );

  Map<String, dynamic> toMap() => {
        "IdBarang": idBarang,
        "NamaBarang": namaBarang,
        "Harga": harga,
        "Stock": stock,
      };
}

class CustomerModel {
  final int idCust;
  final String namaCust;
  final String? alamat;
  final int? noHp;

  CustomerModel({
    required this.idCust,
    required this.namaCust,
    this.alamat,
    this.noHp,
  });

  factory CustomerModel.fromMap(Map<String, dynamic> json) => CustomerModel(
        idCust: json["IdCust"],
        namaCust: json["NamaCust"],
        alamat: json["Alamat"],
        noHp: json["NoHp"],
      );

  Map<String, dynamic> toMap() => {
        "IdCust": idCust,
        "NamaCust": namaCust,
        "Alamat": alamat,
        "NoHp": noHp,
      };
}

class UserModel {
  String? username;
  String? password;
  String? role;

  UserModel({
    this.username,
    this.password,
    this.role,
  });
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
      'role': role,
    };
  }

  UserModel.fromMap(Map<String, dynamic> map) {
    this.username = map['username'];
    this.password = map['password'];
    this.role = map['role'];
  }
}

class PenjualanModel {
  final int noFaktur;
  final int? idCust;
  final DateTime? tanggal;
  final String? username;

  PenjualanModel({
    required this.noFaktur,
    this.idCust,
    this.tanggal,
    this.username,
  });

  factory PenjualanModel.fromMap(Map<String, dynamic> json) => PenjualanModel(
        noFaktur: json["NoFaktur"],
        idCust: json["IdCust"],
        tanggal:
            json["Tanggal"] != null ? DateTime.parse(json["Tanggal"]) : null,
        username: json["Username"],
      );

  Map<String, dynamic> toMap() => {
        "NoFaktur": noFaktur,
        "IdCust": idCust,
        "Tanggal": tanggal?.toIso8601String(),
        "Username": username,
      };
}

class DetailPenjualanModel {
  final int noFaktur;
  final int idBarang;
  final int qty;
  final int harga;

  DetailPenjualanModel({
    required this.noFaktur,
    required this.idBarang,
    required this.qty,
    required this.harga,
  });

  factory DetailPenjualanModel.fromMap(Map<String, dynamic> json) =>
      DetailPenjualanModel(
        noFaktur: json["NoFaktur"],
        idBarang: json["IdBarang"],
        qty: json["Qty"],
        harga: json["Harga"],
      );

  Map<String, dynamic> toMap() => {
        "NoFaktur": noFaktur,
        "IdBarang": idBarang,
        "Qty": qty,
        "Harga": harga,
      };
}

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  final String tableUser = 'tableUser';
  final String username = 'username';
  final String password = 'password';
  final String role = 'role';

  DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  Future<Database?> get _db async {
    if (_database != null) {
      return _database;
    }
    _database = await _initDatabase();
    return _database;
  }

  Future<Database?> _initDatabase() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'transaksi.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
      CREATE TABLE $tableUser(
        $username TEXT PRIMARY KEY,
        $password TEXT,
        $role TEXT
      )
    ''');
        print('$tableUser table created.');
      },
    );
  }

  Future<int?> insertUser(UserModel user) async {
    var dbClient = await _db;
    return await dbClient!.insert(
      tableUser,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List?> getAllUser() async {
    var dbClient = await _db;
    var result = await dbClient!.query(tableUser, columns: [
      username,
      password,
      role,
    ]);

    return result.map((map) => UserModel.fromMap(map)).toList();
  }

  Future<Map<String, dynamic>?> validateUser(
      String username, String password) async {
    final db = await _initDatabase();
    var res = await db?.query("tableUser",
        where: "username = ? and password = ?",
        whereArgs: [username, password]);

    if (res?.isNotEmpty ?? false) {
      return {
        'isValid': true,
        'role': res![0]['role'],
      };
    } else {
      return {'isValid': false, 'role': null};
    }
  }

  Future<int?> updateUser(UserModel user) async {
    var dbClient = await _db;
    return await dbClient!.update(tableUser, user.toMap(),
        where: '$username = ?', whereArgs: [user.username]);
  }

  //hapus database
  Future<int?> deleteUser(String username) async {
    var dbClient = await _db;
    return await dbClient!
        .delete(tableUser, where: '$username = ?', whereArgs: [username]);
  }
}

// Open the database
// Future<Database> get database async {
//   if (_database != null) return _database!;

//   // If _database is null, initialize it
//   _database = await initDatabase();
//   return _database!;
// }

// Initialize the database
// Future<Database> initDatabase() async {
//   String path = join(await getDatabasesPath(), 'user.db');

//   // Open the database
//   return await openDatabase(
//     path,
//     version: 1,
//     onCreate: (Database db, int version) async {
//       // Create tables
//       await db.execute('''
//           CREATE TABLE barang (
//             IdBarang INTEGER PRIMARY KEY,
//             NamaBarang TEXT,
//             Harga INTEGER,
//             Stock INTEGER
//           )
//         ''');

//       await db.execute('''
//           CREATE TABLE customer (
//             IdCust INTEGER PRIMARY KEY,
//             NamaCust TEXT,
//             Alamat TEXT,
//             NoHp INTEGER
//           )
//         ''');

//       await db.execute('''
//           CREATE TABLE penjualan (
//             NoFaktur INTEGER PRIMARY KEY,
//             IdCust INTEGER,
//             Tanggal TEXT,
//             Username TEXT,
//             FOREIGN KEY (IdCust) REFERENCES customer(IdCust),
//             FOREIGN KEY (Username) REFERENCES user(Username)
//           )
//         ''');

//       await db.execute('''
//           CREATE TABLE detail_penjualan (
//             NoFaktur INTEGER,
//             IdBarang INTEGER,
//             Qty INTEGER,
//             Harga INTEGER,
//             PRIMARY KEY (NoFaktur, IdBarang),
//             FOREIGN KEY (NoFaktur) REFERENCES penjualan(NoFaktur),
//             FOREIGN KEY (IdBarang) REFERENCES barang(IdBarang)
//           )
//         ''');
//     },
//   );
// }
