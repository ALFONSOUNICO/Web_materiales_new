import 'dart:math' as math;

import 'package:flutter/material.dart';



import 'models/material.dart';

import 'services/sap_service.dart';
import 'screens/dashboard_page.dart';



void main() {

  runApp(const WebMaterialesApp());

}



class WebMaterialesApp extends StatelessWidget {

  const WebMaterialesApp({super.key});



  @override

  Widget build(BuildContext context) {

    return MaterialApp(

      title: 'Consulta de Materiales SAP',

      debugShowCheckedModeBanner: false,

      theme: ThemeData(

        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(

          seedColor: const Color(0xFF1565C0),

        ),

        scaffoldBackgroundColor: const Color(0xFFF4F7FB),

        fontFamily: 'Arial',

      ),

      home: const LoginPage(),

    );

  }

}




class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _mostrarPassword = false;

  @override
  void dispose() {
    _usuarioController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _ingresar() {
    final usuario = _usuarioController.text.trim();
    final password = _passwordController.text;

    if (usuario.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe ingresar usuario y contraseña.'),
        ),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => MaterialesPage(
          usuario: usuario,
          password: password,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF2FC),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.lock_outline,
                        size: 38,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Acceso a SAP',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF123B66),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ingrese sus credenciales para continuar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 28),
                    TextField(
                      controller: _usuarioController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Usuario SAP',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: !_mostrarPassword,
                      onSubmitted: (_) => _ingresar(),
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          tooltip: _mostrarPassword
                              ? 'Ocultar contraseña'
                              : 'Mostrar contraseña',
                          onPressed: () {
                            setState(() {
                              _mostrarPassword = !_mostrarPassword;
                            });
                          },
                          icon: Icon(
                            _mostrarPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _ingresar,
                        icon: const Icon(Icons.login),
                        label: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Text('Ingresar'),
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MaterialesPage extends StatefulWidget {

  final String usuario;

  final String password;



  const MaterialesPage({

    super.key,

    required this.usuario,

    required this.password,

  });



  @override

  State<MaterialesPage> createState() => _MaterialesPageState();

}



class _MaterialesPageState extends State<MaterialesPage> {

  final SapService _sapService = SapService();



  final TextEditingController _materialDesdeController =

      TextEditingController();



  final TextEditingController _materialHastaController =

      TextEditingController();



  DateTime? _fechaDesde;

  DateTime? _fechaHasta;



  MaterialResponse? _response;



  bool _cargando = false;



  String? _error;



  int _pageSize = 20;

  int _offset = 0;



  @override

  void dispose() {

    _materialDesdeController.dispose();

    _materialHastaController.dispose();

    super.dispose();

  }



  String _formatearFecha(DateTime fecha) {

    final year = fecha.year.toString().padLeft(4, '0');

    final month = fecha.month.toString().padLeft(2, '0');

    final day = fecha.day.toString().padLeft(2, '0');



    return '$year-$month-$day';

  }



  Future<void> _seleccionarFecha(bool desde) async {

    final fechaInicial = desde

        ? (_fechaDesde ?? DateTime.now())

        : (_fechaHasta ?? _fechaDesde ?? DateTime.now());



    final fecha = await showDatePicker(

      context: context,

      initialDate: fechaInicial,

      firstDate: DateTime(2000),

      lastDate: DateTime(2100),

      helpText: desde ? 'Seleccione Fecha Inicio' : 'Seleccione Fecha Fin',

      cancelText: 'Cancelar',

      confirmText: 'Aceptar',

    );



    if (fecha == null) {

      return;

    }



    setState(() {

      if (desde) {

        _fechaDesde = fecha;



        if (_fechaHasta != null && _fechaHasta!.isBefore(fecha)) {

          _fechaHasta = null;

        }

      } else {

        _fechaHasta = fecha;

      }

    });

  }



  Future<void> _consultar() async {

    FocusScope.of(context).unfocus();



    setState(() {

      _error = null;

    });



    final materialDesde = _materialDesdeController.text.trim();

    final materialHasta = _materialHastaController.text.trim();



    if (materialDesde.isEmpty || materialHasta.isEmpty) {

      setState(() {

        _error = 'Debe indicar Material Desde y Material Hasta.';

      });

      return;

    }



    if (_fechaDesde == null || _fechaHasta == null) {

      setState(() {

        _error = 'Debe indicar Fecha Inicio y Fecha Fin.';

      });

      return;

    }



    if (_fechaHasta!.isBefore(_fechaDesde!)) {

      setState(() {

        _error = 'La Fecha Fin no puede ser menor que la Fecha Inicio.';

      });

      return;

    }



    setState(() {

      _cargando = true;

      _offset = 0;

      _response = null;

    });



    try {

      final resultado = await _sapService.consultarMateriales(

  usuario: widget.usuario,

  password: widget.password,

  materialDesde: materialDesde,

  materialHasta: materialHasta,

  fechaDesde: _formatearFecha(_fechaDesde!),

  fechaHasta: _formatearFecha(_fechaHasta!),

  pageSize: _pageSize,

  offset: 0,

);



      if (!mounted) {

        return;

      }



      setState(() {

        _response = resultado;

        _cargando = false;

      });

    } catch (e) {

      if (!mounted) {

        return;

      }



      setState(() {

        _cargando = false;

        _error = 'No fue posible consultar SAP.\n\n$e';

      });

    }

  }



  Future<void> _cambiarPagina(int nuevoOffset) async {

    if (_response == null) {

      return;

    }



    if (nuevoOffset < 0 || nuevoOffset >= _response!.total) {

      return;

    }



    final materialDesde = _materialDesdeController.text.trim();

    final materialHasta = _materialHastaController.text.trim();



    if (_fechaDesde == null || _fechaHasta == null) {

      return;

    }



    setState(() {

      _cargando = true;

      _error = null;

    });



    try {

      final resultado = await _sapService.consultarMateriales(
        usuario: widget.usuario,
        password: widget.password,

        materialDesde: materialDesde,

        materialHasta: materialHasta,

        fechaDesde: _formatearFecha(_fechaDesde!),

        fechaHasta: _formatearFecha(_fechaHasta!),

        pageSize: _pageSize,

        offset: nuevoOffset,

      );



      if (!mounted) {

        return;

      }



      setState(() {

        _response = resultado;

        _offset = nuevoOffset;

        _cargando = false;

      });

    } catch (e) {

      if (!mounted) {

        return;

      }



      setState(() {

        _cargando = false;

        _error = 'No fue posible obtener la página solicitada.\n\n$e';

      });

    }

  }



  void _cambiarPageSize(int nuevoTamano) {

    setState(() {

      _pageSize = nuevoTamano;

      _offset = 0;

    });



    if (_response != null) {

      _consultar();

    }

  }



  Widget _campoMaterial({

    required String label,

    required TextEditingController controller,

  }) {

    return SizedBox(

      width: 250,

      child: TextField(

        controller: controller,

        decoration: InputDecoration(

          labelText: label,

          hintText: 'Ej. 000000110601400016',

          prefixIcon: const Icon(Icons.inventory_2_outlined),

          border: OutlineInputBorder(

            borderRadius: BorderRadius.circular(10),

          ),

          filled: true,

          fillColor: Colors.white,

        ),

      ),

    );

  }



  Widget _campoFecha({

    required String label,

    required DateTime? fecha,

    required VoidCallback onPressed,

  }) {

    return SizedBox(

      width: 210,

      child: InkWell(

        onTap: onPressed,

        borderRadius: BorderRadius.circular(10),

        child: InputDecorator(

          decoration: InputDecoration(

            labelText: label,

            prefixIcon: const Icon(Icons.calendar_month_outlined),

            border: OutlineInputBorder(

              borderRadius: BorderRadius.circular(10),

            ),

            filled: true,

            fillColor: Colors.white,

          ),

          child: Text(

            fecha == null ? 'Seleccione fecha' : _formatearFecha(fecha),

            style: TextStyle(

              color: fecha == null

                  ? Colors.grey.shade600

                  : Colors.black87,

              fontSize: 15,

            ),

          ),

        ),

      ),

    );

  }



  Future<void> _abrirDashboard() async {
    if (_response == null || _response!.total == 0) return;

    final materialDesde = _materialDesdeController.text.trim();
    final materialHasta = _materialHastaController.text.trim();
    if (_fechaDesde == null || _fechaHasta == null) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: SizedBox(
          width: 360,
          child: Row(
            children: [
              SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 3)),
              SizedBox(width: 18),
              Expanded(child: Text('Preparando Dashboard...\nAnalizando todos los materiales y posiciones VBAP.')),
            ],
          ),
        ),
      ),
    );

    try {
      final materiales = <MaterialSap>[];
      const lote = 100;
      final total = _response!.total;

      for (int offset = 0; offset < total; offset += lote) {
        final tamano = math.min(lote, total - offset);
        final resultado = await _sapService.consultarMateriales(
          usuario: widget.usuario,
          password: widget.password,
          materialDesde: materialDesde,
          materialHasta: materialHasta,
          fechaDesde: _formatearFecha(_fechaDesde!),
          fechaHasta: _formatearFecha(_fechaHasta!),
          pageSize: tamano,
          offset: offset,
        );
        materiales.addAll(resultado.materiales);
        if (resultado.materiales.isEmpty) break;
      }

      if (mounted) Navigator.of(context).pop();
      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DashboardPage(
            materiales: materiales,
            fechaDesde: _formatearFecha(_fechaDesde!),
            fechaHasta: _formatearFecha(_fechaHasta!),
            totalEsperado: total,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        setState(() => _error = 'No fue posible preparar el Dashboard.\n\n$e');
      }
    }
  }

  Widget _panelConsulta() {

    return Card(

      elevation: 1,

      margin: EdgeInsets.zero,

      shape: RoundedRectangleBorder(

        borderRadius: BorderRadius.circular(16),

      ),

      child: Padding(

        padding: const EdgeInsets.all(22),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Row(

              children: [

                Icon(

                  Icons.search,

                  color: Theme.of(context).colorScheme.primary,

                ),

                const SizedBox(width: 10),

                const Text(

                  'Parámetros de consulta',

                  style: TextStyle(

                    fontSize: 19,

                    fontWeight: FontWeight.bold,

                  ),

                ),

              ],

            ),

            const SizedBox(height: 20),

            Wrap(

              spacing: 16,

              runSpacing: 16,

              children: [

                _campoMaterial(

                  label: 'Material Desde',

                  controller: _materialDesdeController,

                ),

                _campoMaterial(

                  label: 'Material Hasta',

                  controller: _materialHastaController,

                ),

                _campoFecha(

                  label: 'Fecha Inicio',

                  fecha: _fechaDesde,

                  onPressed: () => _seleccionarFecha(true),

                ),

                _campoFecha(

                  label: 'Fecha Fin',

                  fecha: _fechaHasta,

                  onPressed: () => _seleccionarFecha(false),

                ),

                SizedBox(

                  width: 180,

                  child: DropdownButtonFormField<int>(

                    initialValue: _pageSize,

                    decoration: InputDecoration(

                      labelText: 'Registros por página',

                      prefixIcon: const Icon(Icons.view_list_outlined),

                      border: OutlineInputBorder(

                        borderRadius: BorderRadius.circular(10),

                      ),

                      filled: true,

                      fillColor: Colors.white,

                    ),

                    items: const [

                      DropdownMenuItem(

                        value: 10,

                        child: Text('10'),

                      ),

                      DropdownMenuItem(

                        value: 20,

                        child: Text('20'),

                      ),

                      DropdownMenuItem(

                        value: 50,

                        child: Text('50'),

                      ),

                      DropdownMenuItem(

                        value: 100,

                        child: Text('100'),

                      ),

                    ],

                    onChanged: (value) {

                      if (value != null) {

                        _cambiarPageSize(value);

                      }

                    },

                  ),

                ),

              ],

            ),

            const SizedBox(height: 22),

            Row(

              children: [

                FilledButton.icon(

                  onPressed: _cargando ? null : _consultar,

                  icon: _cargando

                      ? const SizedBox(

                          width: 18,

                          height: 18,

                          child: CircularProgressIndicator(

                            strokeWidth: 2,

                            color: Colors.white,

                          ),

                        )

                      : const Icon(Icons.search),

                  label: Text(

                    _cargando ? 'Consultando...' : 'Consultar SAP',

                  ),

                  style: FilledButton.styleFrom(

                    padding: const EdgeInsets.symmetric(

                      horizontal: 24,

                      vertical: 16,

                    ),

                  ),

                ),

                const SizedBox(width: 12),

                OutlinedButton.icon(

                  onPressed: _cargando

                      ? null

                      : () {

                          setState(() {

                            _materialDesdeController.clear();

                            _materialHastaController.clear();

                            _fechaDesde = null;

                            _fechaHasta = null;

                            _response = null;

                            _error = null;

                            _offset = 0;

                          });

                        },

                  icon: const Icon(Icons.clear),

                  label: const Text('Limpiar'),

                ),

              ],

            ),

          ],

        ),

      ),

    );

  }



  Widget _panelResumen() {
    if (_response == null) return const SizedBox.shrink();

    final total = _response!.total;
    final desde = _offset + 1;
    final hasta = (_offset + _response!.materiales.length).clamp(0, total);

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 35,
              runSpacing: 15,
              children: [
                _datoResumen('Total materiales', total.toString(), Icons.inventory_2_outlined),
                _datoResumen('Mostrando', total == 0 ? '0' : '$desde - $hasta de $total', Icons.format_list_numbered),
                _datoResumen('Fecha desde', _response!.fechaDesde, Icons.calendar_today_outlined),
                _datoResumen('Fecha hasta', _response!.fechaHasta, Icons.event_outlined),
              ],
            ),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _cargando ? null : _abrirDashboard,
                icon: const Icon(Icons.dashboard_customize_outlined),
                label: const Text('Ver Dashboard'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _datoResumen(

    String titulo,

    String valor,

    IconData icono,

  ) {

    return Row(

      mainAxisSize: MainAxisSize.min,

      children: [

        Icon(

          icono,

          size: 27,

          color: Theme.of(context).colorScheme.primary,

        ),

        const SizedBox(width: 10),

        Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text(

              titulo,

              style: TextStyle(

                color: Colors.grey.shade700,

                fontSize: 12,

              ),

            ),

            Text(

              valor,

              style: const TextStyle(

                fontSize: 17,

                fontWeight: FontWeight.bold,

              ),

            ),

          ],

        ),

      ],

    );

  }



  Widget _tablaMaterial(MaterialSap material) {

    return Card(

      elevation: 1,

      margin: const EdgeInsets.only(bottom: 16),

      shape: RoundedRectangleBorder(

        borderRadius: BorderRadius.circular(14),

      ),

      clipBehavior: Clip.antiAlias,

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Container(

            width: double.infinity,

            padding: const EdgeInsets.symmetric(

              horizontal: 18,

              vertical: 14,

            ),

            color: const Color(0xFFEAF2FC),

            child: Wrap(

              spacing: 35,

              runSpacing: 8,

              children: [

                _datoMaterial('Material', material.matnr),

                _datoMaterial('Creado', material.ersda),

                _datoMaterial('Usuario', material.ernam),

              ],

            ),

          ),

          if (material.vbap.isEmpty)

            const Padding(

              padding: EdgeInsets.all(20),

              child: Row(

                children: [

                  Icon(

                    Icons.info_outline,

                    color: Colors.grey,

                  ),

                  SizedBox(width: 10),

                  Text(

                    'No existen posiciones VBAP para este material '

                    'en el rango de fechas seleccionado.',

                    style: TextStyle(

                      color: Colors.grey,

                      fontStyle: FontStyle.italic,

                    ),

                  ),

                ],

              ),

            )

          else

            SingleChildScrollView(

              scrollDirection: Axis.horizontal,

              child: DataTable(

                headingRowColor: WidgetStatePropertyAll(

                  Color(0xFFF5F7FA),

                ),

                columns: const [

                  DataColumn(label: Text('Documento')),

                  DataColumn(label: Text('Posición')),

                  DataColumn(label: Text('Material')),

                  DataColumn(label: Text('WAVWR')),

                  DataColumn(label: Text('MWSBP')),

                  DataColumn(label: Text('Fecha')),

                  DataColumn(label: Text('Usuario')),

                ],

                rows: material.vbap.map((posicion) {

                  return DataRow(

                    cells: [

                      DataCell(Text(posicion.vbeln)),

                      DataCell(Text(posicion.posnr.toString())),

                      DataCell(Text(posicion.matnr)),

                      DataCell(

                        Text(posicion.wavwr.toStringAsFixed(2)),

                      ),

                      DataCell(

                        Text(posicion.mwsbp.toStringAsFixed(2)),

                      ),

                      DataCell(Text(posicion.erdat)),

                      DataCell(Text(posicion.ernam)),

                    ],

                  );

                }).toList(),

              ),

            ),

        ],

      ),

    );

  }



  Widget _datoMaterial(String titulo, String valor) {

    return RichText(

      text: TextSpan(

        style: const TextStyle(

          color: Colors.black87,

          fontSize: 14,

        ),

        children: [

          TextSpan(

            text: '$titulo: ',

            style: const TextStyle(

              fontWeight: FontWeight.bold,

            ),

          ),

          TextSpan(text: valor),

        ],

      ),

    );

  }



  Widget _resultados() {

    if (_response == null) {

      return const SizedBox.shrink();

    }



    if (_response!.materiales.isEmpty) {

      return Card(

        elevation: 1,

        child: Padding(

          padding: const EdgeInsets.all(30),

          child: Center(

            child: Text(

              _response!.message.isEmpty

                  ? 'No se encontraron materiales.'

                  : _response!.message,

              style: const TextStyle(fontSize: 16),

            ),

          ),

        ),

      );

    }



    return Column(

      children: _response!.materiales

          .map(_tablaMaterial)

          .toList(),

    );

  }



  Widget _paginacion() {
    if (_response == null || _response!.total <= _pageSize) {
      return const SizedBox.shrink();
    }

    final totalPaginas = (_response!.total / _pageSize).ceil();
    final paginaActual = (_offset ~/ _pageSize) + 1;

    final puedeAnterior = paginaActual > 1;
    final puedeSiguiente = paginaActual < totalPaginas;

    final paginas = <int>[];

    if (totalPaginas <= 7) {
      for (int i = 1; i <= totalPaginas; i++) {
        paginas.add(i);
      }
    } else {
      paginas.add(1);

      if (paginaActual > 4) {
        paginas.add(-1);
      }

      final inicio = paginaActual <= 4 ? 2 : paginaActual - 1;
      final fin = paginaActual >= totalPaginas - 3
          ? totalPaginas - 1
          : paginaActual + 1;

      for (int i = inicio; i <= fin; i++) {
        if (!paginas.contains(i)) {
          paginas.add(i);
        }
      }

      if (paginaActual < totalPaginas - 3) {
        paginas.add(-1);
      }

      if (!paginas.contains(totalPaginas)) {
        paginas.add(totalPaginas);
      }
    }

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(top: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        child: Column(
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              runSpacing: 8,
              children: [
                IconButton(
                  tooltip: 'Primera página',
                  onPressed: puedeAnterior
                      ? () => _cambiarPagina(0)
                      : null,
                  icon: const Icon(Icons.first_page),
                ),

                IconButton(
                  tooltip: 'Página anterior',
                  onPressed: puedeAnterior
                      ? () => _cambiarPagina(
                            (paginaActual - 2) * _pageSize,
                          )
                      : null,
                  icon: const Icon(Icons.chevron_left),
                ),

                ...paginas.map((pagina) {
                  if (pagina == -1) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        '...',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }

                  final seleccionada = pagina == paginaActual;

                  return SizedBox(
                    width: 40,
                    height: 40,
                    child: FilledButton(
                      onPressed: seleccionada
                          ? null
                          : () => _cambiarPagina(
                                (pagina - 1) * _pageSize,
                              ),
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: seleccionada
                            ? const Color(0xFF0D47A1)
                            : null,
                        foregroundColor: seleccionada
                            ? Colors.white
                            : const Color(0xFF0D47A1),
                      ),
                      child: Text(
                        pagina.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),

                IconButton(
                  tooltip: 'Página siguiente',
                  onPressed: puedeSiguiente
                      ? () => _cambiarPagina(
                            paginaActual * _pageSize,
                          )
                      : null,
                  icon: const Icon(Icons.chevron_right),
                ),

                IconButton(
                  tooltip: 'Última página',
                  onPressed: puedeSiguiente
                      ? () => _cambiarPagina(
                            (totalPaginas - 1) * _pageSize,
                          )
                      : null,
                  icon: const Icon(Icons.last_page),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              'Página $paginaActual de $totalPaginas',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        backgroundColor: const Color(0xFF0D47A1),

        foregroundColor: Colors.white,

        elevation: 2,

        title: const Row(

          children: [

            Icon(Icons.storage_rounded),

            SizedBox(width: 12),

            Text(

              'Consulta de Materiales SAP',

              style: TextStyle(

                fontWeight: FontWeight.bold,

              ),

            ),

          ],

        ),

      ),

      body: Center(

        child: ConstrainedBox(

          constraints: const BoxConstraints(

            maxWidth: 1500,

          ),

          child: SingleChildScrollView(

            padding: const EdgeInsets.all(24),

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [

                const Text(

                  'Materiales y documentos de venta',

                  style: TextStyle(

                    fontSize: 28,

                    fontWeight: FontWeight.bold,

                    color: Color(0xFF123B66),

                  ),

                ),

                const SizedBox(height: 6),

                Text(

                  'Consulta información de MARA y sus posiciones VBAP '

                  'desde SAP S/4HANA.',

                  style: TextStyle(

                    fontSize: 15,

                    color: Colors.grey.shade700,

                  ),

                ),

                const SizedBox(height: 24),

                _panelConsulta(),

                if (_error != null) ...[

                  const SizedBox(height: 16),

                  Card(

                    color: const Color(0xFFFFF3F3),

                    child: Padding(

                      padding: const EdgeInsets.all(16),

                      child: Row(

                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [

                          const Icon(

                            Icons.error_outline,

                            color: Colors.red,

                          ),

                          const SizedBox(width: 12),

                          Expanded(

                            child: Text(

                              _error!,

                              style: const TextStyle(

                                color: Colors.red,

                              ),

                            ),

                          ),

                        ],

                      ),

                    ),

                  ),

                ],

                if (_response != null) ...[

                  const SizedBox(height: 20),

                  _panelResumen(),

                  const SizedBox(height: 20),

                  _resultados(),

                  _paginacion(),

                ],

              ],

            ),

          ),

        ),

      ),

    );

  }

}
