import 'package:ace_routes/database/Tables/login_response_table.dart';
import 'package:ace_routes/database/Tables/terms_data_table.dart';
import 'package:ace_routes/model/login_model/login_response.dart';
import 'package:ace_routes/model/login_model/token_api_response.dart';
import 'package:ace_routes/model/terms_model.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:xml/xml.dart';

import '../database/Tables/api_data_table.dart';

class AllTermsController {
  String token = "";
  String accountName = "";
  String workerRid = "";
  String url = "";

  Future<void> GetAllTerms() async {
    final respone = await http.get(Uri.parse(
        "https://${url}/mobi?token=$token&nspace=${accountName}&geo=<lat,lon>&rid=136675&action=getterm"));

    print(token);
    print("response :${respone.body}");

    if (respone.statusCode == 200) {
      final xmlReponse = XmlDocument.parse(respone.body);

      final namespace = xmlReponse.findAllElements('nsp').single.text;
      final locationCode = xmlReponse.findAllElements('lofc').single.text;
      final formName = xmlReponse.findAllElements('lfrm').single.text;
      final partName = xmlReponse.findAllElements('lprt').single.text;
      final assetName = xmlReponse.findAllElements('lass').single.text;
      final pictureLabel = xmlReponse.findAllElements('lpic').single.text;
      final audioLabel = xmlReponse.findAllElements('laud').single.text;
      final signatureLabel = xmlReponse.findAllElements('lsig').single.text;
      final fileLabel = xmlReponse.findAllElements('lfil').single.text;
      final workLabel = xmlReponse.findAllElements('lwrk').single.text;
      final customerLabel = xmlReponse.findAllElements('lcst').single.text;
      final orderLabel = xmlReponse.findAllElements('lord').single.text;
      final customerReferenceLabel =
          xmlReponse.findAllElements('lordnm').single.text;
      final registrationLabel = xmlReponse.findAllElements('lpo').single.text;
      final odometerLabel = xmlReponse.findAllElements('linv').single.text;
      final detailsLabel = xmlReponse.findAllElements('ldtl').single.text;
      final faultDescriptionLabel =
          xmlReponse.findAllElements('lalt').single.text;
      final notesLabel = xmlReponse.findAllElements('lnot').single.text;
      final summaryLabel = xmlReponse.findAllElements('lsum').single.text;
      final orderGroupLabel = xmlReponse.findAllElements('lordgrp').single.text;
      final fieldOrderRules =
          xmlReponse.findAllElements('fldordrls').single.text;
      final invoiceEmailLabel =
          xmlReponse.findAllElements('lordfld1').single.text;

      TermsDataModel termsDataModel = TermsDataModel(
          namespace: namespace,
          locationCode: locationCode,
          formName: formName,
          partName: partName,
          assetName: assetName,
          pictureLabel: pictureLabel,
          audioLabel: audioLabel,
          signatureLabel: signatureLabel,
          fileLabel: fileLabel,
          workLabel: workLabel,
          customerLabel: customerLabel,
          orderLabel: orderLabel,
          customerReferenceLabel: customerReferenceLabel,
          registrationLabel: registrationLabel,
          odometerLabel: odometerLabel,
          detailsLabel: detailsLabel,
          faultDescriptionLabel: faultDescriptionLabel,
          notesLabel: notesLabel,
          summaryLabel: summaryLabel,
          orderGroupLabel: orderGroupLabel,
          fieldOrderRules: fieldOrderRules,
          invoiceEmailLabel: invoiceEmailLabel);

      await TermsDataTable.insertTermsData(termsDataModel);

      print('sucessfully added in all terms in table ');
    }
  }

  Future<void> displayLoginResponseData() async {
    // Fetch the list of login responses from the database
    List<LoginResponse> dataList =
        await LoginResponseTable.fetchLoginResponses();

    // Optionally print each field separately
    for (var data in dataList) {
      accountName = data.nsp;
      url = data.url;

      print('NSP: ${data.nsp}');
      print('URL: ${data.url}');
      print('Subkey: ${data.subkey}');
    }

    //-------------------------
    List<TokenApiReponse> tokenData = await ApiDataTable.fetchData();

    for (var data in tokenData) {
      token = data.token;
      print('Responder Name:  ${data.responderName}');
      print('GeoLocation: ${data.geoLocation}');
    }
  }
}
