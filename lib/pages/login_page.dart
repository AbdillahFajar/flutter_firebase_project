import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
class MyLogin extends StatefulWidget {
  const MyLogin({super.key});

  @override
  State<MyLogin> createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool _isLoading = false; /*Nilai awal _isLoading adalah false. _isLoading berfungsi sebagai acuan untuk aplikai menentukan tampilannya (UI), 
                            jadi, UI akan dipengaruhi berdasarkan keadaan _isLoading, apakah true atau false. 
                             Dalam halaman login ini, yang dipengaruhi tampilannya berdasarkan keadaan _isLoading adalah tombol 'Login' yang menggunakan ElevatedButton.*/
  String? _error; //nilai awal _error belum didefinisikan tapi telah dibuat sebagai String yang nilainya boleh null.
  
  Future<void>_login() async {

    //keadaan awal yang terjadi ketika tombol login di-klik, sehingga memanggil _login untuk bekerja, dan proses login pun berjalan dengan firebase mulai mencocokkan hasil inputan dari user di field email dan password
    setState(() {
      _isLoading = true; //tombol login jadi disable dan berubah menjadi loading circular
      _error = null; //_error di-set ke null, karena setiap kali tombol login di-klik, maka selama proses login berjalan, tidak akan ada error apapun sampai firebase tidak menemukan adanya kesalahan dari inputan user di field email dan password atau dari aplikasinya sendiri
    });

    //
    try{
      //mengambil hasil inputan user di field email dan password
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailCtrl.text.trim(),//mengambil inputan berupa text dari field email dan menghapus spasi di tiap ujung (ujung kiri dan kanan) tulisan emailnya
        password: passCtrl.text,//mengambil inputan text dari field password 
      );
      
      final user = credential.user; //cek atau ambil user yang sesuai dengan hasil inputan email dan password yang dimasukkan

      if(!mounted) return; //ini mencegah aplikasi crash ketika widget aplikasi di-dispose (dihilangkan) oleh flutter karena perilaku user, contohnya, keluar dari aplikasi

      //ini bakalan muncul kalo login berhasil, yaitu kumpulan tulisan yang disusun di dalam semacam card. kenapa pake !mounted?
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Login Success'),
          content: Text('UID: ${user?.uid}\nEmail: ${user?.email}'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child:const Text('OK'))],
        ),
      );
    }
    //bikin catch untuk pesan error khusus autentikasi firebase yang menangani salah satunya, kalau login gak berhasil (salah email atau password atau keduanya atau bahkan form dikosongkan tapi maksa klik 'Login').
    on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.message;
      });
    }
    catch (e) { //catch untuk pesan error umum yang selain dari autentikasi firebase. contoh, internet mati, error parsing, error kode program, request timeout, dll
      setState(() {
        _error = e.toString();
      });
    }
    finally { /*ini untuk bagian "pembersihan". di halaman ini, maksudnya adalah me-reset _isLoading kembali menjadi false, agar tombol bisa aktif (bisa diklik), dan loading circular-nya hilang. 
                karena berdasarkan penggunaan _isLoading di ElevatedButton login, jika true (?), maka tombol login akan null, yang artinya akan disable atau gak bisa diklik dan akan muncul loading circular. 
                sehingga, jika gak ditangani dengan finally, maka tombolnya akan terus gak bisa diklik dan loading circular-nya akan terus muncul. maka dari itu, setelah nulis isi try dan catch, 
                finally harus ditulis juga isinya yang berkaitan dengan "pembersihan". contoh lain dari "pembersihan" di finally ini adalah menutup koneksi ke database ketika gak pake firebase atau pake db-manual.*/
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter x Firebase Practice'),
        centerTitle: true, 
        backgroundColor: Colors.pinkAccent,
      ),
      body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              
              const SizedBox(height: 8),

              TextField(
                controller: passCtrl,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true, //ini bikin inputan yang dimasukkan user gak bisa disalin atau dicopy
              ),

              const SizedBox(height: 16),

              //logika if yang digunakan ketika ada error terdeteksi, apapun jenisnya, baik dari sisi autentikasi ataupun dari sisi selain itu (baca lagi bagian catch umum)
              if(_error != null) 
              ...[ //isi logikanya dibungkus dengan kurung siku (artinya, isi dari logika if menggunakan list), karena bukan cuma nampilin satu widget aja yaitu, tulisan error, tapi juga nambahin spasi (SizedBox) ketika tulisan error itu  muncul, sehingga ada space di bawah tulisannya yang gak akan ngebiarin tulisan itu nempel dengan tombol login di bawahnya
                Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8), //titik tiga (...) di sana adalah spread operator, yang gunanya untuk memisahkan setiap widget di dalam if itu menjadi widget yang terpisah, bukan satu widget
              ],
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading ? const CircularProgressIndicator() : const Text('Login'),
              ),
            ],
          ),
        ),
    );
  }
}