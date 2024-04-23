import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
class ProjectForm extends StatefulWidget {
  const ProjectForm({super.key});

  @override
  State<ProjectForm> createState() => _ProjectFormState();
}

class _ProjectFormState extends State<ProjectForm> {
  final TextEditingController _nameController=TextEditingController();
  final TextEditingController _descController=TextEditingController();
  final TextEditingController _clientController=TextEditingController();
  final TextEditingController _orgController=TextEditingController();
  final TextEditingController _projectedController=TextEditingController();
  final TextEditingController _amountController=TextEditingController();
  final TextEditingController _currencyController=TextEditingController();
   TextEditingController dateinput = TextEditingController(); 
    TextEditingController dateout = TextEditingController(); 
  //text editing controller for text field
  
  @override
  void initState() {
    dateinput.text = "";
    dateout.text=""; //set the initial value of text field
    super.initState();
  }
  @override
  void dispose(){
    _nameController.dispose();
    _descController.dispose();
    _clientController.dispose();
    _orgController.dispose();
    _projectedController.dispose();
    _amountController.dispose();
    _currencyController.dispose();
    super.dispose();
  } 
  String dropdownvalue='Complete';
  var items=[
    'Complete',
    'Incomplete'
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:SingleChildScrollView(
        child:Column(children: [
             TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Title', 
                  border: OutlineInputBorder(
                       
                          borderSide: BorderSide(width: 3, color: Colors.grey),
                        ),),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter a title';
                    }
                    return null;
                  },
                ),
                 TextFormField(
                  controller: _descController,
                  decoration: InputDecoration(labelText: 'Description', 
                  border: OutlineInputBorder(
                       
                          borderSide: BorderSide(width: 3, color: Colors.grey),
                        ),),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter a description';
                    }
                    return null;
                  },
                ),
                
                TextField(
                controller: dateinput, //editing controller of this TextField
                decoration: InputDecoration( 
                   icon: Icon(Icons.calendar_today), //icon of text field
                   labelText: "Enter Start Date" //label text of field
                ),
                readOnly: true,  //set it true, so that user will not able to edit text
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                      context: context, initialDate: DateTime.now(),
                      firstDate: DateTime(2000), //DateTime.now() - not to allow to choose before today.
                      lastDate: DateTime(2101)
                  );
                  
                  if(pickedDate != null ){
                      print(pickedDate);  //pickedDate output format => 2021-03-10 00:00:00.000
                      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate); 
                      print(formattedDate); //formatted date output using intl package =>  2021-03-16
                        //you can implement different kind of Date Format here according to your requirement

                      setState(() {
                         dateinput.text = formattedDate; //set output date to TextField value. 
                      });
                  }else{
                      print("Date is not selected");
                  }
                },
             ),
              TextField(
                controller: dateout, //editing controller of this TextField
                decoration: InputDecoration( 
                   icon: Icon(Icons.calendar_today), //icon of text field
                   labelText: "Enter End Date" //label text of field
                ),
                readOnly: true,  //set it true, so that user will not able to edit text
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                      context: context, initialDate: DateTime.now(),
                      firstDate: DateTime(2000), //DateTime.now() - not to allow to choose before today.
                      lastDate: DateTime(2101)
                  );
                  
                  if(pickedDate != null ){
                      print(pickedDate);  //pickedDate output format => 2021-03-10 00:00:00.000
                      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate); 
                      print(formattedDate); //formatted date output using intl package =>  2021-03-16
                        //you can implement different kind of Date Format here according to your requirement

                      setState(() {
                         dateout.text = formattedDate; //set output date to TextField value. 
                      });
                  }else{
                      print("Date is not selected");
                  }
                },
             ),
             TextFormField(
                  controller: _clientController,
                  decoration: InputDecoration(labelText: 'Client assigned', 
                  border: OutlineInputBorder(
                       
                          borderSide: BorderSide(width: 3, color: Colors.grey),
                        ),),
                  
                ),
                TextFormField(
                  controller: _orgController,
                  decoration: InputDecoration(labelText: 'Organisation', 
                  border: OutlineInputBorder(
                       
                          borderSide: BorderSide(width: 3, color: Colors.grey),
                        ),),
                
                ),
                 TextFormField(
                  controller: _currencyController,
                  decoration: InputDecoration(labelText: 'Currency', 
                  border: OutlineInputBorder(
                       
                          borderSide: BorderSide(width: 3, color: Colors.grey),
                        ),),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter your currency';
                    }
                    return null;
                  },
                ),
                 TextFormField(
                  controller: _projectedController,
                  decoration: InputDecoration(labelText: 'Projected Amount', 
                  border: OutlineInputBorder(
                       
                          borderSide: BorderSide(width: 3, color: Colors.grey),
                        ),),
        
                ),
                 TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(labelText: 'Amount paid', 
                  border: OutlineInputBorder(
                       
                          borderSide: BorderSide(width: 3, color: Colors.grey),
                        ),),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter the amount';
                    }
                    return null;
                  },
                ),
               
                InputDecorator(
                        decoration: InputDecoration(
                          labelText:
                              'Employee Status', // Add a label if desired
                          border: OutlineInputBorder(
                            // Customize the border
                            borderRadius:
                                BorderRadius.circular(5.0), // Border radius
                            borderSide: const BorderSide(
                              // Border color and width
                              color: Colors.blue, // Border color
                              width: 1.0, // Border width
                            ),
                          ),
                        ),
                        child: DropdownButton(
                          // Initial Value
                          value: dropdownvalue,

                          // Down Arrow Icon
                          icon: const Icon(Icons.keyboard_arrow_down),

                          // Array list of items
                          items: items.map((String items) {
                            return DropdownMenuItem(
                              value: items,
                              child: Text(items),
                            );
                          }).toList(),
                          // After selecting the desired option,it will
                          // change button value to selected value
                          onChanged: (String? newValue) {
                            setState(() {
                              dropdownvalue = newValue!;
                            });
                          },
                        ),
                      ),
        ],)
      )
    );
  }
}