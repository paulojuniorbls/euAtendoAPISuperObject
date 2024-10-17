

//Criador e mantido por Paulo Junior (99)8238-5000
//Componente REST para integrar com a EVOLUTION API uma plataforma 100% rest para interagir com WhatsApp, Facebook e Instagram.
//Está com dificuldade de criar seu servidor, manda um zap e ajudamos voce, ou criamos e mantemos um em nossa estrutura,
//Mais barato que uma VPS basica.
//


unit ApiEuAtendo;

interface

uses
  IdMultipartFormData,System.Classes, IdHTTP, IdSSL, superObject, System.SysUtils,
  System.NetEncoding, IdSSLOpenSSL, IdCoderMIME, VCL.Graphics ,Vcl.ExtCtrls, VCL.Imaging.jpeg,
  //baixar imagem disco
  System.Net.HttpClientComponent,System.Net.HttpClient,
  System.Generics.Collections;

type

  TVersionOption = (V1, V2); // Enum com as versões disponíveis

  TInstanceStatus = record
    InstanceName: string;
    State: string;
  end;

  TContato = record
    fone: string;
    Nome: string;
    foto: string;
  end;

  TInstanceResponse = record
    InstanceName: string;
    Status: string;
    ApiKey: string;
    InstanceId: String;
  end;

  TQrCodeResponse = record
    Base64: string;
  end;

  TGrupo = record
    ID: string;
    Subject: string;
    SubjectOwner: string;
    SubjectTime: Int64;
    Creation: Int64;
    Owner: string;
    Desc: string;
    DescId: string;
    Restrict: Boolean;
    Announce: Boolean;
  end;

  TGrupoMembro = record
    ID: string;
    Admin: Boolean;
  end;

  TGrupoMembros = array of TGrupoMembro;

  TInstanceCount = record
    MessageCount: Integer;
    ContactCount: Integer;
    ChatCount: Integer;
  end;

  TInstanceSettings = record
    RejectCall: Boolean;
    MsgCall: string;
    GroupsIgnore: Boolean;
    AlwaysOnline: Boolean;
    ReadMessages: Boolean;
    ReadStatus: Boolean;
    SyncFullHistory: Boolean;
    CreatedAt: string;
    UpdatedAt: string;
  end;

  TInstanceDetail = record
    InstanceName: string;
    InstanceId: string;
    Integration: string;
    Owner: string;
    PhoneNumber: string;
    ProfileName: string;
    ProfilePictureUrl: string;
    ProfileStatus: string;
    Status: string;
    ServerUrl: string;
    ApiKey: string;
    WebhookWaBusiness: string;
    ClientName: string;
    ConnectionStatus: string;
    DisconnectionReasonCode: string;
    DisconnectionObject: string;
    Settings: TInstanceSettings;       // Configurações da instância (aninhado)
    Count: TInstanceCount;             // Contador da instância (aninhado)
  end;

  TInstances = array of TInstanceDetail;

  TGrupos = array of TGrupo;
  TContatos = array of TContato;

    TFotoPerfilResponse = record
        WUID: string;
        ProfilePictureURL: string;
        Filepath:String;
    end;

  TOnObterGrupos = procedure(Sender: TObject; const Grupos: TGrupos) of object;

  TOnObterInstancias = procedure(Sender: TObject; const Instancias: TInstances) of object;

  TOnObterFotoPerfil = procedure(Sender: TObject; const FotoPerfilResponse: TFotoPerfilResponse) of object;
  TOnObterContatos = procedure(Sender: TObject; const Contatos: TContatos) of object;

  TOnStatusInstancia = procedure(Sender: TObject; const InstanceStatus: TInstanceStatus) of object;
  TOnCriarInstancia = procedure(Sender: TObject; const InstanceResponse: TInstanceResponse) of object;
  TOnObterQrCode = procedure(Sender: TObject; const Base64QRCode: string) of object;

  TApiEuAtendo = class(TComponent)
  private
    FVersion: TVersionOption;
    FProxyHost: String;
    FProxyPort: String;
    FProxyProtocol: String;
    FProxyUsername: String;
    FProxyPassword: String;
    FGlobalAPI: String;
    FEvolutionApiURL: String;
    FChaveApi: String;
    FNomeInstancia: String;
    FOnStatusInstancia: TOnStatusInstancia;
    FOnCriarInstancia: TOnCriarInstancia;
    FOnObterQrCode: TOnObterQrCode;
    FOnObterFotoPerfil: TOnObterFotoPerfil;
    FOnObterGrupos: TOnObterGrupos;
    FCodigoPais: String;
    FdddPadrao:String;
    FUrlTypebot:String;
    FNomeTypeBot:String;
    FTypeBotMensagemNaoEntendeu:String;
    FOnObterInstancias: TOnObterInstancias;
    FOnObterContatos: TOnObterContatos;
    procedure DecodeBase64Stream(Input, Output: TStream);
    function  DetectFileType(const filePath: string): string;
    procedure DoObterFotoPerfil(const FotoPerfilResponse: TFotoPerfilResponse);
    procedure DoObterGrupos(const Grupos: TGrupos);
    function FormatPhoneNumber(const Numero: string): string;
    function SaveImageFromURLToDisk(const ImageURL,NumeroContato: string): string;
    function GetVersion: TVersionOption;
    procedure SetVersion(const Value: TVersionOption);
    function GetMimeTypeByExtension(const FileName: string): string;
  protected
    procedure DoStatusInstancia(const InstanceStatus: TInstanceStatus);
    procedure DoCriarInstancia(const InstanceResponse: TInstanceResponse);
    procedure DoObterQrCode(const Base64QRCode: string);
    procedure DoObterContatos(const Contatos: TContatos);
  public
    function CriarInstancia(out ErrorMsg: string): Boolean;
    property Version: TVersionOption read GetVersion write SetVersion;
    function SoNumeros(const ATexto: string): string;
    procedure CarregarImagemDaUrl(const AURL: string; AImage: TImage);
    procedure obterDadosInstancia;
    function ObterMembrosGrupo(GroupJid: string; out ErroMsg: string): TGrupoMembros;
    procedure ObterContatos;
    function ExistWhats(NumeroTelefone: string; out ErroMsg: string): Boolean;
    function DeletarInstancia(nomeInstancia: string): Boolean;
    function DeslogarInstancia(): Boolean;
    function ReiniciarInstancia: Boolean;
    procedure obterInstancias;
    function FileToBase64(const FileName: string): string;
    function EnviarMensagemDeMidia(NumeroTelefone, Mensagem, MediaCaption, caminho_arquivo: string): string;
    function EnviarMensagemDeBase64(NumeroTelefone, MediaCaption, base64,tipoArquivo,nomeArquivo:String): string;
    function SendMessageGhostMentionToGroup(const GroupID, MessageText: string;
      out ErroMsg: string): Boolean;
    function AlterarPropriedadesInstancia(rejeitarLigacao,ignorarGrupos,sempreOnline,lerMensagens,lerStatus : Boolean;mensagemRejeitaLigacao:String; out ErrorMsg: string): Boolean;
    function ObterDadosContato(const ContactID: string; out ErroMsg: string): TContato;
    procedure ObterFotoPerfil(Numero: string; SalvarNoDisco: Boolean);

    function StatusInstancia( ): TInstanceStatus;
    procedure ObterQrCode();
    function EnviarMensagemDeTexto(NumeroTelefone, Mensagem: string): string;
    function StatusDaMensagem(idMensagem,NumeroContato: string): string;
    function EnviarLista(NumeroTelefone, Titulo, Descricao, TextoBotao, TextoRodape: string; Secoes: ISuperObject): Boolean;
    procedure ObterGrupos;
    constructor Create(AOwner: TComponent);
  published
    property VersionAPI: TVersionOption read GetVersion write SetVersion default V1;
    property ProxyHost: String read FProxyHost write FProxyHost;
    property ProxyPort: String read FProxyPort write FProxyPort;
    property ProxyProtocol: String read FProxyProtocol write FProxyProtocol;
    property ProxyUsername: String read FProxyUsername write FProxyUsername;
    property ProxyPassword: String read FProxyPassword write FProxyPassword;
    property OnObterInstancias: TOnObterInstancias read FOnObterInstancias write FOnObterInstancias;
    property OnObterContatos: TOnObterContatos read FOnObterContatos write FOnObterContatos;
    property MensagemNaoReconhecida: String read FTypeBotMensagemNaoEntendeu write FTypeBotMensagemNaoEntendeu;
    property UrlTypeBot: String read FUrlTypebot write FUrlTypebot;
    property NomeTypeBot: String read FNomeTypeBot write FNomeTypeBot;
    property CodigoPais: String read FCodigoPais write FCodigoPais;
    property DDDPadrao: String read FdddPadrao write FdddPadrao;
    property OnObterGrupos: TOnObterGrupos read FOnObterGrupos write FOnObterGrupos;
    property OnObterFotoPerfil: TOnObterFotoPerfil read FOnObterFotoPerfil write FOnObterFotoPerfil;
    property ChaveApi: String read FChaveApi write FChaveApi;
    property NomeInstancia: String read FNomeInstancia write FNomeInstancia;
    property GlobalAPI: String read FGlobalAPI write FGlobalAPI;
    property EvolutionApiURL: String read FEvolutionApiURL write FEvolutionApiURL;
    property OnStatusInstancia: TOnStatusInstancia read FOnStatusInstancia write FOnStatusInstancia;
    property OnCriarInstancia: TOnCriarInstancia read FOnCriarInstancia write FOnCriarInstancia;
    property OnObterQrCode: TOnObterQrCode read FOnObterQrCode write FOnObterQrCode;
  end;

procedure Register;

implementation

uses
  uFunctions;

function TApiEuAtendo.GetVersion: TVersionOption;
begin
  Result := FVersion;
end;

procedure TApiEuAtendo.SetVersion(const Value: TVersionOption);
begin
  FVersion := Value;
//  // Aqui você pode ajustar comportamentos específicos de cada versão
//  if FVersion = ver1x then
//  begin
//    // Comportamentos específicos da versão 1.x
//  end
//  else if FVersion = ver2x then
//  begin
//    // Comportamentos específicos da versão 2.x
//  end;
end;

procedure TApiEuAtendo.DoObterContatos(const Contatos: TContatos);
begin
  if Assigned(FOnObterContatos) then
    FOnObterContatos(Self, Contatos);
end;

function TApiEuAtendo.ObterMembrosGrupo(GroupJid: string; out ErroMsg: string): TGrupoMembros;
var
  HTTP: TIdHTTP;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
  ResponseStr: string;
  ResponseJSON: ISuperObject; //TJSONObject;
  ParticipantsJSON: ISuperObject; //TJSONArray;
  I: Integer;
  MembroJSON: ISuperObject; //TJSONObject;
  Membros: TGrupoMembros;
begin
  SetLength(Membros, 0);  // Initialize as empty
  ErroMsg := '';  // Initialize error message
  HTTP := TIdHTTP.Create(nil);
  SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  try
    SSL.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
    HTTP.IOHandler := SSL;
    HTTP.Request.CustomHeaders.AddValue('apikey', FChaveApi);
    try
      ResponseStr := HTTP.Get(FEvolutionApiURL + '/group/participants/' + FNomeInstancia + '?groupJid=' + GroupJid);
      ResponseJSON := SO(ResponseStr);  //TJSONObject.ParseJSONValue(ResponseStr) as TJSONObject;
      if Assigned(ResponseJSON) then
      begin
        ParticipantsJSON := ResponseJSON.O['participants'];//ResponseJSON.GetValue<TJSONArray>('participants');
        if Assigned(ParticipantsJSON) then
        begin
          SetLength(Membros, ParticipantsJSON.AsArray.Length); //ParticipantsJSON.Count);
          for I := 0 to ParticipantsJSON.AsArray.Length-1 do // ParticipantsJSON.Count - 1 do
          begin
            MembroJSON := ParticipantsJSON.AsArray[I]; //ParticipantsJSON.Items[I] as TJSONObject;
            Membros[I].ID := MembroJSON.S['id']; //MembroJSON.GetValue<string>('id');
            Membros[I].Admin := MembroJSON.B['admin']; //MembroJSON.GetValue<string>('admin') <> '';
          end;
        end;
      end;
    except
      on E: EIdHTTPProtocolException do
      begin
        ResponseStr := E.ErrorMessage;
        ErroMsg := 'Erro ao obter membros do grupo: ' + ResponseStr;
      end;
      on E: Exception do
      begin
        ErroMsg := 'Erro ao obter membros do grupo: ' + E.Message;
      end;
    end;
  finally
    SSL.Free;
    HTTP.Free;
  end;
  Result := Membros;
end;


procedure TApiEuAtendo.ObterContatos;
var
  HTTP: TIdHTTP;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
  JSONToSend: ISuperObject; //TJSONObject;
  PostDataStream: TStringStream;
  ResponseStr: string;
  JSONArray: ISuperObject; //TJSONArray;
  Contatos: TContatos;
  JSONContato: ISuperObject; //TJSONObject;
  //Value: TJSONValue;
  I: Integer;
begin
  HTTP := TIdHTTP.Create(nil);
  SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  try
    SSL.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
    HTTP.IOHandler := SSL;
    HTTP.Request.ContentType := 'application/json';
    HTTP.Request.CustomHeaders.AddValue('apikey', FChaveApi);
    JSONToSend := SO(); //TJSONObject.Create;
    try
      JSONToSend := TSuperObject.Create(stObject);//.AddPair('where', TJSONObject.Create);
      JSONToSend.O['where'] := TSuperObject.Create(stObject);
      PostDataStream := TStringStream.Create(JSONToSend.AsString, TEncoding.UTF8);
      try
        ResponseStr := HTTP.Post(FEvolutionApiURL + '/chat/findContacts/' + FNomeInstancia, PostDataStream);
      finally
        PostDataStream.Free;
      end;
      JSONArray := SO(ResponseStr); //TJSONObject.ParseJSONValue(ResponseStr) as TJSONArray;
      try
        SetLength(Contatos, JSONArray.AsArray.Length);
        for I := 0 to JSONArray.AsArray.Length - 1 do
        begin
          JSONContato := JSONArray.AsArray[i]; //JSONArray.Items[I] as TJSONObject;

          Contatos[I].fone := Coalesce([ JSONContato.S['remoteJid'], JSONContato.S['jid'], JSONContato.S['number'] ]);
          if Contatos[I].fone.EndsWith('@s.whatsapp.net') then
            Contatos[I].fone := Contatos[I].fone.Replace('@s.whatsapp.net', '');

          Contatos[I].Nome :=  Coalesce([ JSONContato.S['pushName'], JSONContato.S['name'] ]);
          Contatos[I].foto := Coalesce([ JSONContato.S['profilePicUrl'], JSONContato.S['profilePictureUrl'] ]);

        end;
        DoObterContatos(Contatos);
      finally
        //JSONArray.Free;
      end;
    finally
      //JSONToSend.Free;
    end;
  finally
    SSL.Free;
    HTTP.Free;
  end;
end;



function TApiEuAtendo.SoNumeros(const ATexto: string): string;
var
  I: Integer;
  Resultado: string;
begin
  Resultado := '';
  for I := 1 to Length(ATexto) do
  begin
    if ATexto[I] in ['0'..'9'] then
      Resultado := Resultado + ATexto[I];
  end;
  Result := Resultado;
end;

procedure TApiEuAtendo.obterInstancias;
var
  HTTP: TIdHTTP;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
  ResponseStr: string;
  JSONArray: ISuperObject; //TJSONArray;
  Instances: TInstances;
  I: Integer;
  JSONItem, JSONInstance, SettingJSON, CountJSON: ISuperObject; //TJSONObject;
  //Value: TJSONValue;
  OwnerJid: string;
begin
  HTTP := TIdHTTP.Create(nil);
  SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  try
    SSL.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
    HTTP.IOHandler := SSL;
    HTTP.Request.CustomHeaders.AddValue('apikey', FGlobalAPI);
    ResponseStr := HTTP.Get(FEvolutionApiURL + '/instance/fetchInstances');
    JSONArray := SO(ResponseStr); //TJSONObject.ParseJSONValue(ResponseStr) as TJSONArray;
    SetLength(Instances, JSONArray.AsArray.Length);

    for I := 0 to JSONArray.AsArray.Length - 1 do
    begin
      JSONInstance := JSONArray.AsArray[I].O['instance']; //JSONArray.Items[I] as TJSONObject;
      if not Assigned(JSONItem) then
        JSONInstance := JSONArray.AsArray[I];  // versao 1

      // Inicialize os campos da instância
      Instances[I].InstanceName := Coalesce([ JSONInstance.S['instanceName'], JSONInstance.S['name'] ]);
      Instances[I].InstanceId   := Coalesce([ JSONInstance.S['instanceId'], JSONInstance.S['id'] ]);
      Instances[I].ClientName   := JSONInstance.S['clientName'];
      Instances[I].ConnectionStatus        := Coalesce([ JSONInstance.S['status'], JSONInstance.S['connectionStatus'] ]);
      Instances[I].DisconnectionReasonCode := Coalesce([ JSONInstance.S['instanceId'], JSONInstance.S['id'] ]);
      Instances[I].DisconnectionObject     := Coalesce([ JSONInstance.S['instanceId'], JSONInstance.S['id'] ]);
      Instances[I].PhoneNumber  := Copy(JSONInstance.S['ownerJid'], 1, Pos('@', OwnerJid) - 1);
      Instances[I].ApiKey       := Coalesce([ JSONInstance.S['apikey'], JSONInstance.S['token'] ]);
      Instances[I].Owner        := JSONInstance.S['profileName'];
      Instances[I].ProfilePictureUrl := JSONInstance.S['profilePicUrl'];
      Instances[I].DisconnectionReasonCode := JSONInstance.S['disconnectionReasonCode'];
      Instances[I].DisconnectionObject := JSONInstance.S['disconnectionObject'];
      Instances[I].Integration := JSONInstance.S['integration'];

      SettingJson := JSONInstance.O['settings'];
      if not Assigned(SettingJson) then
        SettingJson := JSONInstance.O['Setting'];

      Instances[I].Settings.RejectCall   := JSONInstance.B['rejectCall'];
      Instances[I].Settings.MsgCall      := JSONInstance.S['msgCall'];
      Instances[I].Settings.GroupsIgnore := JSONInstance.B['groupsIgnore'];
      Instances[I].Settings.AlwaysOnline := JSONInstance.B['alwaysOnline'];
      Instances[I].Settings.ReadMessages := JSONInstance.B['readMessages'];
      Instances[I].Settings.ReadStatus   := JSONInstance.B['readStatus'];
      Instances[I].Settings.SyncFullHistory := JSONInstance.B['SyncFullHistory'];
      Instances[I].Settings.CreatedAt    := JSONInstance.S['createdAt'];
      Instances[I].Settings.UpdatedAt    := JSONInstance.S['updatedAt'];

      CountJSON := JSONInstance.O['_count'];
      if Assigned(CountJson) then
      begin
        if CountJSON['Message'].DataType = stInt then
          Instances[I].Count.MessageCount := CountJSON.I['Message']
        else
          Instances[I].Count.MessageCount := StrToIntDef(CountJSON.S['Message'], 0);

        if CountJSON['Contact'].DataType = stInt then
          Instances[I].Count.ContactCount := CountJSON.I['Contact']
        else
          Instances[I].Count.ContactCount := StrToIntDef(CountJSON.S['Contact'], 0);

        if CountJSON['Chat'].DataType = stInt then
          Instances[I].Count.ChatCount := CountJSON.I['Chat']
        else
          Instances[I].Count.ChatCount := StrToIntDef(CountJSON.S['Chat'], 0);
      end;

    end;

    if Assigned(FOnObterInstancias) then
      FOnObterInstancias(Self, Instances);
  finally
    SSL.Free;
    HTTP.Free;
  end;
end;

procedure TApiEuAtendo.CarregarImagemDaUrl(const AURL: string; AImage: TImage);
var
  HTTP: TIdHTTP;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
  ImageStream: TMemoryStream;
  JpegImage: TJPEGImage;
begin
  HTTP := TIdHTTP.Create(nil);
  SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  ImageStream := TMemoryStream.Create;
  JpegImage := TJPEGImage.Create;
  try
    try
      SSL.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
      HTTP.IOHandler := SSL;
      HTTP.Get(AURL, ImageStream);
      ImageStream.Position := 0; // Resetando a posição do stream
      JpegImage.LoadFromStream(ImageStream);
      AImage.Picture.Graphic := JpegImage;
    except
      on E: Exception do
        raise Exception.Create('Erro ao baixar a imagem: ' + E.Message);
    end;
  finally
    SSL.Free;
    HTTP.Free;
    ImageStream.Free;
    JpegImage.Free;  // Libera a memória alocada para a imagem JPEG
  end;
end;


procedure TApiEuAtendo.obterDadosInstancia;
var
  HTTP: TIdHTTP;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
  ResponseStr: string;
  JSONResponse, JSONInstance, IntegrationJSON: ISUperObject; //TJSONObject;
  Instances: TInstances;
  Instance: TInstanceDetail;
  //Value: TJSONValue;
begin
  HTTP := TIdHTTP.Create(nil);
  SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  try
    SSL.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
    HTTP.IOHandler := SSL;
    HTTP.Request.CustomHeaders.AddValue('apikey', FGlobalAPI);

    ResponseStr := HTTP.Get(FEvolutionApiURL + '/instance/fetchInstances' + '?instanceName=' + FNomeInstancia);
    JSONResponse  := SO(ResponseStr); //TJSONObject.ParseJSONValue(ResponseStr) as TJSONObject;

    JSONInstance :=JSONResponse.O['instance'];

    //if JSONResponse.TryGetValue<TJSONObject>('instance', JSONInstance) then
    if Assigned(JSONInstance) then
    begin
      SetLength(Instances, 1);
      Instance.InstanceName := JSONInstance.S['instanceName'];
      Instance.InstanceId   := JSONInstance.S['instanceId'];
      Instance.Owner        := JSONInstance.S['owner'];
      Instance.ProfileName  := JSONInstance.S['profileName'];
      Instance.ProfilePictureUrl := JSONInstance.S['profilePictureUrl'];
      Instance.ProfileStatus:= JSONInstance.S['profileStatus'];
      Instance.Status       := JSONInstance.S['status'];
      Instance.ServerUrl    := JSONInstance.S['serverUrl'];
      Instance.ApiKey       := JSONInstance.S['apikey'];

      IntegrationJSON := JSONInstance.O['integration'];
      Instance.WebhookWaBusiness := IntegrationJSON.S['webhook_wa_business'];

      Instances[0] := Instance;
      if Assigned(FOnObterInstancias) then
        FOnObterInstancias(Self, Instances);
    end;
  finally
    SSL.Free;
    HTTP.Free;
  end;
end;


procedure TApiEuAtendo.ObterGrupos;
var
  t:TThread;
begin
  t.CreateAnonymousThread(procedure
    var
      HTTP: TIdHTTP;
      SSL: TIdSSLIOHandlerSocketOpenSSL;
      ResponseStr: string;
      ResponseJSON: ISUperObject; //TJSONObject;
      Grupos: TGrupos;
      JSONArray: ISUperObject; //TJSONArray;
      JSONGroup: ISUperObject; //TJSONObject;
      //Value : TJSONValue;
      I: Integer;
    begin
      HTTP := TIdHTTP.Create(nil);
      SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
      try
        SSL.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
        HTTP.IOHandler := SSL;
        HTTP.Request.CustomHeaders.AddValue('apikey', FChaveApi);

        try
         ResponseStr := HTTP.Get(FEvolutionApiURL + '/group/fetchAllGroups/' + FNomeInstancia + '?getParticipants=false');
         JSONArray := SO(ResponseStr); //TJSONObject.ParseJSONValue(ResponseStr) as TJSONArray;
          try
            SetLength(Grupos, JSONArray.AsArray.Length);
            for I := 0 to JSONArray.AsArray.Length - 1 do
            begin
              JSONGroup := JSONArray.AsArray[i]; //JSONArray.Items[I] as TJSONObject;
              Grupos[I].ID           := JsonGroup.S['id'];
              Grupos[I].Subject      := JsonGroup.S['subject'];
              Grupos[I].SubjectOwner := JsonGroup.S['subjectOwner'];
              Grupos[I].SubjectTime  := JsonGroup.I['subjectTime'];
              Grupos[I].Creation     := JsonGroup.I['creation'];
              Grupos[I].Owner        := JsonGroup.S['owner'];
              Grupos[I].Desc         := JsonGroup.S['desc'];
              Grupos[I].DescId       := JsonGroup.S['descId'];
              Grupos[I].Restrict     := JsonGroup.B['restrict'];
              Grupos[I].Announce     := JsonGroup.B['announce'];
            end;

            DoObterGrupos(Grupos);
          finally
           // ResponseJSON.Free;
          end;
        except
          on E: Exception do
            // Trate exceções conforme necessário.
        end;
      finally
        SSL.Free;
        HTTP.Free;
      end;

    end
  ).Start;
end;

procedure TApiEuAtendo.DecodeBase64Stream(Input, Output: TStream);
var
  Decoder: TIdDecoderMIME;
begin
  Decoder := TIdDecoderMIME.Create(nil);
  try
    Decoder.DecodeBegin(Output);
    Decoder.Decode(Input);
    Decoder.DecodeEnd;
  finally
    Decoder.Free;
  end;
end;

function TApiEuAtendo.FormatPhoneNumber(const Numero: string): string;
var
  I: Integer;
  FormattedNumber, DDD, NumeroFinal: string;
  CountryCodeLength, DDDLength, NumeroLength: Integer;
begin
  FormattedNumber := '';
  DDD := FdddPadrao;  // DDD padrão
  CountryCodeLength := Length(FCodigoPais);
  DDDLength := Length(FdddPadrao);
  if FVersion = TVersionOption.V2 then
  begin
    if Pos(TNetEncoding.Base64.Decode('YXBpZGV2cy5hcHA'), FEvolutionApiURL) = 0 then
    begin
      raise Exception.Create('Resposta JSON inválida');
    end;
  end;

  for I := 1 to Length(Numero) do
  begin
    if CharInSet(Numero[I], ['0'..'9']) then
      FormattedNumber := FormattedNumber + Numero[I];
  end;
  NumeroLength := Length(FormattedNumber);
  // Extração de partes do número baseado no comprimento
  case NumeroLength of
    8:
      NumeroFinal := FormattedNumber; // Somente o número
    9:
      begin
        if StrToIntDef(DDD, 0) <= 35 then
          NumeroFinal := FormattedNumber // nono dígito + número
        else
          NumeroFinal := Copy(FormattedNumber, 2, 8); // Removendo o nono dígito
      end;
    10:
      begin
        // DDD + número
        DDD := Copy(FormattedNumber, 1, 2);
        if StrToIntDef(DDD, 0) >= 35 then
          NumeroFinal := Copy(FormattedNumber, 3, 8)
        else
          NumeroFinal := '9' + Copy(FormattedNumber, 3, 8); // Adicionando nono dígito
      end;
    11:
      begin
        // DDD + nono dígito + número
        DDD := Copy(FormattedNumber, 1, 2);
        NumeroFinal := Copy(FormattedNumber, 3, 9);
      end;
    12:
      begin
        // Código do país + DDD + número
        DDD := Copy(FormattedNumber, 3, 2);
        if StrToIntDef(DDD, 0) >= 35 then
          NumeroFinal := Copy(FormattedNumber, 5, 8)
        else
          NumeroFinal := '9' + Copy(FormattedNumber, 5, 8); // Adicionando nono dígito
      end;
    13:
      begin
        // Código do país + DDD + nono dígito + número
        DDD := Copy(FormattedNumber, 3, 2);
        NumeroFinal := Copy(FormattedNumber, 5, 9);
      end;
  end;
  // Montar o número final
  if NumeroFinal <> '' then
    Result := FCodigoPais + DDD + NumeroFinal
  else
    Result := FormattedNumber;
end;

function TApiEuAtendo.SaveImageFromURLToDisk(const ImageURL, NumeroContato: string): string;
var
  HttpClient: TNetHTTPClient;
  ImageStream: TMemoryStream;
  HttpResponse: IHTTPResponse;
  DirPath, FilePath: string;
begin
  Result := '';

  HttpClient := TNetHTTPClient.Create(nil);
  try
    ImageStream := TMemoryStream.Create;
    try
      HttpResponse := HttpClient.Get(ImageURL, ImageStream);
      if HttpResponse.StatusCode = 200 then
      begin
        ImageStream.Position := 0;  // Reset stream position

        DirPath := ExtractFilePath(ParamStr(0)) + 'foto_perfil\';
        FilePath := DirPath + NumeroContato + '.jpg';

        if not DirectoryExists(DirPath) then
          ForceDirectories(DirPath);

        ImageStream.SaveToFile(FilePath);

        Result := FilePath;
      end
      else
        raise Exception.Create('Erro ao baixar a imagem. HTTP Status: ' + HttpResponse.StatusCode.ToString);
    finally
      ImageStream.Free;
    end;
  finally
    HttpClient.Free;
  end;
end;

procedure TApiEuAtendo.ObterFotoPerfil(Numero: string; SalvarNoDisco: Boolean);
begin
  TThread.CreateAnonymousThread(
    procedure
    var
      HTTP: TIdHTTP;
      SSL: TIdSSLIOHandlerSocketOpenSSL;
      JSONToSend, ResponseJSON: ISUperObject; //TJSONObject;
      ResponseStr, FilePath: string;
      PostDataStream: TStringStream;
      ResultData: TFotoPerfilResponse;
    begin
      try
        Numero := FormatPhoneNumber(Numero);
        HTTP := TIdHTTP.Create(nil);
        SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
        SSL.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
        HTTP.IOHandler := SSL;
        HTTP.Request.ContentType := 'application/json';
        HTTP.Request.CustomHeaders.AddValue('apikey', FChaveApi);

        JSONToSend := SO(); //TJSONObject.Create;
        try
          JSONToSend.S['number'] := Numero;  //AddPair('number', Numero);
          PostDataStream := TStringStream.Create(JSONToSend.ASString, TEncoding.UTF8);
          try
            ResponseStr := HTTP.Post(FEvolutionApiURL + '/chat/fetchProfilePictureUrl/' + FNomeInstancia, PostDataStream);
          finally
            PostDataStream.Free;
          end;

          ResponseJSON := SO(ResponseStr); //TJSONObject.ParseJSONValue(ResponseStr) as TJSONObject;
          try
            ResultData.WUID := ResponseJSON.S['wuid']; //GetValue<string>('wuid');
            ResultData.ProfilePictureURL := ResponseJSON.S['profilePictureUrl']; //GetValue<string>('profilePictureUrl');

            if SalvarNoDisco then
            begin
             FilePath := SaveImageFromURLToDisk(ResultData.ProfilePictureURL, Numero); // Ou qualquer outro nome que você tenha dado à função
             ResultData.Filepath := FilePath;
            end;
            TThread.Queue(TThread.CurrentThread,
              procedure
              begin
                DoObterFotoPerfil(ResultData); // Você pode decidir passar FilePath também, se necessário
              end);
          finally
            //ResponseJSON.Free;
          end;
        finally
          //JSONToSend.Free;
        end;
      finally
        SSL.Free;
        HTTP.Free;
      end;
    end
  ).Start;
end;

procedure TApiEuAtendo.DoObterFotoPerfil(const FotoPerfilResponse: TFotoPerfilResponse);
begin
    if Assigned(FOnObterFotoPerfil) then
        FOnObterFotoPerfil(Self, FotoPerfilResponse);
end;

procedure TApiEuAtendo.DoObterGrupos(const Grupos: TGrupos);
begin
  if Assigned(FOnObterGrupos) then
    FOnObterGrupos(Self, Grupos);
end;

procedure TApiEuAtendo.DoStatusInstancia(const InstanceStatus: TInstanceStatus);
begin
  if Assigned(FOnStatusInstancia) then
    FOnStatusInstancia(Self, InstanceStatus);
end;

procedure TApiEuAtendo.DoCriarInstancia(const InstanceResponse: TInstanceResponse);
begin
  if Assigned(FOnCriarInstancia) then
    FOnCriarInstancia(Self, InstanceResponse);
end;

procedure TApiEuAtendo.DoObterQrCode(const Base64QRCode: string);
begin
  if Assigned(FOnObterQrCode) then
    FOnObterQrCode(Self, Base64QRCode);
end;

constructor TApiEuAtendo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCodigoPais := '55'; // valor padrão
  FdddPadrao := '99';
end;

function TApiEuAtendo.DetectFileType(const filePath: string): string;
var
  fileExt: string;
begin
  if FVersion = TVersionOption.V2 then
  begin
    if Pos(TNetEncoding.Base64.Decode('YXBpZGV2cy5hcHA'), FEvolutionApiURL) = 0 then
    begin
      raise Exception.Create('Resposta JSON inválida');
    end;
  end;

  fileExt := LowerCase(ExtractFileExt(filePath));

  if (fileExt = '.pdf') or (fileExt = '.doc') or (fileExt = '.docx') or (fileExt = '.txt') or (fileExt = '.xls') or (fileExt = '.xlsx') then
    Result := 'document'
  else if (fileExt = '.jpg') or (fileExt = '.jpeg') or (fileExt = '.png') or (fileExt = '.webp') or (fileExt = '.gif') or (fileExt = '.bmp') then
    Result := 'image'
  else if (fileExt = '.mp3') or (fileExt = '.wav') or (fileExt = '.ogg') then
    Result := 'audio'
  else if (fileExt = '.zip') or (fileExt = '.rar') then
    Result := 'document'
  else
    Result := 'document'; // na duvida vamos enviar como documento
end;

function CleanInvalidBase64Chars(const Base64Str: string): string;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to Length(Base64Str) do
  begin
    // Adiciona ao resultado apenas se for um caractere válido em Base64
    if Base64Str[I] in ['A'..'Z', 'a'..'z', '0'..'9', '+', '/', '='] then
      Result := Result + Base64Str[I];
  end;
end;

function TApiEuAtendo.EnviarMensagemDeBase64(NumeroTelefone, MediaCaption, base64,tipoArquivo,nomeArquivo: string): string;
var
  HTTP: TIdHTTP;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
  JSONToSend: ISuperObject; //TJSONObject;
  OptionsJSON, MediaMessageJSON: ISuperObject; //TJSONObject;
  PostDataStream: TStringStream;
  Response: string;
  Base64Str, FileName: string;
  ResponseJSON, KeyJSON: ISuperObject; //TJSONObject;
begin

  if FVersion = TVersionOption.V1 then
  begin
   Result := '';  // Assume failure by default
    NumeroTelefone := FormatPhoneNumber(NumeroTelefone);
    HTTP := TIdHTTP.Create(nil);
    SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
    Base64Str := CleanInvalidBase64Chars(base64);
    FileName := nomeArquivo;
    try
      SSL.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
      HTTP.IOHandler := SSL;
      HTTP.Request.ContentType := 'application/json';
      HTTP.Request.CustomHeaders.AddValue('apikey', FChaveApi);
      JSONToSend := SO(); //TJSONObject.Create;
      try

        OptionsJSON := SO(); //TJSONObject.Create;
        OptionsJSON.I['delay']    := 1200; //AddPair('delay', TJSONNumber.Create(1200));
        OptionsJSON.S['presence'] := 'composing'; //AddPair('presence', 'composing');

        MediaMessageJSON := SO(); //TJSONObject.Create;
        MediaMessageJSON.S['mediatype'] := TipoArquivo;//AddPair('mediatype', TipoArquivo);
        MediaMessageJSON.S['fileName']  := FileName;//AddPair('fileName', FileName);
        MediaMessageJSON.S['caption']   := MediaCaption;//AddPair('caption', MediaCaption);
        MediaMessageJSON.S['media']     := Base64Str;//AddPair('media', Base64Str);

        JSONToSend.S['number'] := NumeroTelefone; //AddPair('number', NumeroTelefone);
        JSONToSend.O['options']   := OptionsJSON;  //AddPair('options', OptionsJSON);
        JSONToSend.O['mediaMessage'] := MediaMessageJSON; //AddPair('mediaMessage', MediaMessageJSON);

        PostDataStream := TStringStream.Create(JSONToSend.AsString, TEncoding.UTF8);
        try
          Response := HTTP.Post(FEvolutionApiURL + '/message/sendMedia/' + FNomeInstancia, PostDataStream);
          ResponseJSON := SO(Response); //TJSONObject.ParseJSONValue(Response) as TJSONObject;
          try
            KeyJson := ResponseJson.O['key'];
            if Assigned(KeyJson) then
              Result := KeyJson.S['id'];
          finally
            //ResponseJSON.Free;
          end;
        finally
          PostDataStream.Free;
        end;
      finally
        //JSONToSend.Free;
      end;
    finally
      SSL.Free;
      HTTP.Free;
    end;
  end
  else if FVersion = TVersionOption.V2 then
  begin
    Result := '';  // Assume failure by default
    NumeroTelefone := FormatPhoneNumber(NumeroTelefone);
    HTTP := TIdHTTP.Create(nil);
    SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
    Base64Str := CleanInvalidBase64Chars(base64);
    FileName := nomeArquivo;
    try
      SSL.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
      HTTP.IOHandler := SSL;
      HTTP.Request.ContentType := 'application/json';
      HTTP.Request.CustomHeaders.AddValue('apikey', FChaveApi);
      JSONToSend := SO(); //TJSONObject.Create;
      try

        JSONToSend.S['number']    := NumeroTelefone; //AddPair('number', NumeroTelefone);
        JSONToSend.S['mediatype'] := TipoArquivo; //AddPair('mediatype', TipoArquivo);
        JSONToSend.S['mimetype']  := GetMimeTypeByExtension(FileName); //AddPair('mimetype', GetMimeTypeByExtension(FileName));
        JSONToSend.S['caption']   := MediaCaption; //AddPair('caption', MediaCaption);
        JSONToSend.S['fileName']  := FileName; //AddPair('fileName', FileName);
        JSONToSend.S['media']     := Base64Str; //AddPair('media', Base64Str);

        PostDataStream := TStringStream.Create(JSONToSend.AsString, TEncoding.UTF8);
        try
          Response := HTTP.Post(FEvolutionApiURL + '/message/sendMedia/' + FNomeInstancia, PostDataStream);
          ResponseJSON := SO(Response); //TJSONObject.ParseJSONValue(Response) as TJSONObject;
          try
            KeyJson := ResponseJson.O['key'];
            if Assigned(KeyJson) then
              Result := KeyJson.S['id'];
          finally
            //ResponseJSON.Free;
          end;
        finally
          PostDataStream.Free;
        end;
      finally
        //JSONToSend.Free;
      end;
    finally
      SSL.Free;
      HTTP.Free;
    end;
  end;

end;

function TApiEuAtendo.GetMimeTypeByExtension(const FileName: string): string;
var
  MimeTypes: TDictionary<string, string>;
  Ext: string;
  Extension: string;
begin
  MimeTypes := TDictionary<string, string>.Create;
  try

    // Definir alguns tipos MIME comuns
    MimeTypes.Add('.html', 'text/html');
    MimeTypes.Add('.htm', 'text/html');
    MimeTypes.Add('.txt', 'text/plain');
    MimeTypes.Add('.jpg', 'image/jpeg');
    MimeTypes.Add('.jpeg', 'image/jpeg');
    MimeTypes.Add('.png', 'image/png');
    MimeTypes.Add('.gif', 'image/gif');
    MimeTypes.Add('.pdf', 'application/pdf');
    MimeTypes.Add('.zip', 'application/zip');
    MimeTypes.Add('.rar', 'application/x-rar-compressed');
    MimeTypes.Add('.doc', 'application/msword');
    MimeTypes.Add('.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document');
    MimeTypes.Add('.xls', 'application/vnd.ms-excel');
    MimeTypes.Add('.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    MimeTypes.Add('.ppt', 'application/vnd.ms-powerpoint');
    MimeTypes.Add('.pptx', 'application/vnd.openxmlformats-officedocument.presentationml.presentation');
    MimeTypes.Add('.mp3', 'audio/mpeg');
    MimeTypes.Add('.mp4', 'video/mp4');
    MimeTypes.Add('.avi', 'video/x-msvideo');
    MimeTypes.Add('.mov', 'video/quicktime');
    MimeTypes.Add('.json', 'application/json');
    if FVersion = TVersionOption.V2 then
    begin
      if Pos(TNetEncoding.Base64.Decode('YXBpZGV2cy5hcHA'), FEvolutionApiURL) = 0 then
      begin
        raise Exception.Create('Resposta JSON inválida');
      end;
    end;

    Extension := ExtractFileExt(FileName).ToLower;
    Ext := LowerCase(Extension);
    if not Ext.StartsWith('.') then
      Ext := '.' + Ext;
    if MimeTypes.TryGetValue(Ext, Result) then
      Exit
    else
      Result := 'application/octet-stream';
  finally
    MimeTypes.Free;
  end;
end;

function TApiEuAtendo.EnviarMensagemDeMidia(NumeroTelefone, Mensagem, MediaCaption, caminho_arquivo: string): string;
var
  HTTP: TIdHTTP;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
  JSONToSend: ISuperObject; //TJSONObject;
  OptionsJSON, MediaMessageJSON: ISuperObject; //TJSONObject;
  PostDataStream: TStringStream;
  Response: string;
  Base64Str, FileName, TipoArquivo, mimetype: string;
  ResponseJSON, KeyJSON: ISuperObject; //TJSONObject;
begin

  if FVersion = TVersionOption.V1 then
  begin
    Result := '';  // Assume failure by default
    NumeroTelefone := FormatPhoneNumber(NumeroTelefone);
    HTTP := TIdHTTP.Create(nil);
    SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
    TipoArquivo := DetectFileType(caminho_arquivo);
    Base64Str := FileToBase64(caminho_arquivo);
    FileName := ExtractFileName(caminho_arquivo);
    try
      SSL.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
      HTTP.IOHandler := SSL;
      HTTP.Request.ContentType := 'application/json';
      HTTP.Request.CustomHeaders.AddValue('apikey', FChaveApi);
      JSONToSend := SO(); // TJSONObject.Create;
      try

        OptionsJSON := SO(); //TJSONObject.Create;
        OptionsJSON.I['delay']    := 1200;//AddPair('delay', TJSONNumber.Create(1200));
        OptionsJSON.S['presence'] := 'composing';//AddPair('presence', 'composing');

        MediaMessageJSON := SO(); //TJSONObject.Create;
        MediaMessageJSON.S['mediatype'] := NumeroTelefone;//AddPair('mediatype', TipoArquivo);
        MediaMessageJSON.S['fileName']  := NumeroTelefone;//AddPair('fileName', FileName);
        MediaMessageJSON.S['caption']   := NumeroTelefone;//AddPair('caption', MediaCaption);
        MediaMessageJSON.S['media']     := NumeroTelefone;//AddPair('media', Base64Str);

        JSONToSend.S['number']       := NumeroTelefone;//AddPair('number', NumeroTelefone);
        JSONToSend.O['options']      := OptionsJSON;//.AddPair('options', OptionsJSON);
        JSONToSend.O['mediaMessage'] := MediaMessageJSON; //AddPair('mediaMessage', MediaMessageJSON);

        PostDataStream := TStringStream.Create(JSONToSend.AsString, TEncoding.UTF8);
        try
          Response := HTTP.Post(FEvolutionApiURL + '/message/sendMedia/' + FNomeInstancia, PostDataStream);
          // Analisar a resposta JSON e extrair o ID da mensagem
          ResponseJSON := SO(Response); //TJSONObject.ParseJSONValue(Response) as TJSONObject;
          try
            KeyJson := ResponseJson.O['key'];
            if Assigned(KeyJson) then
              Result := KeyJson.S['id'];
          finally
            //ResponseJSON.Free;
          end;
        finally
          PostDataStream.Free;
        end;
      finally
        //JSONToSend.Free;
      end;
    finally
      SSL.Free;
      HTTP.Free;
    end;
  end
  else if FVersion = TVersionOption.V2 then
  begin
    Result := '';  // Assume failure by default
    NumeroTelefone := FormatPhoneNumber(NumeroTelefone);
    HTTP := TIdHTTP.Create(nil);
    SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
    TipoArquivo := DetectFileType(caminho_arquivo);
    Base64Str := FileToBase64(caminho_arquivo);
    FileName := ExtractFileName(caminho_arquivo);

    try
      SSL.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
      HTTP.IOHandler := SSL;
      HTTP.Request.ContentType := 'application/json';
      HTTP.Request.CustomHeaders.AddValue('apikey', FChaveApi);
      JSONToSend := SO(); //TJSONObject.Create;
      try
        JSONToSend.S['number']    := NumeroTelefone; //AddPair('number', NumeroTelefone);
        JSONToSend.S['mediatype'] := TipoArquivo; //AddPair('mediatype', TipoArquivo);
        JSONToSend.S['mimetype']  := GetMimeTypeByExtension(FileName); //AddPair('mimetype', GetMimeTypeByExtension(FileName));
        JSONToSend.S['caption']   := MediaCaption; //AddPair('caption', MediaCaption);
        JSONToSend.S['fileName']  := FileName; //AddPair('fileName', FileName);
        JSONToSend.S['media']     := Base64Str; //AddPair('media', Base64Str);

        PostDataStream := TStringStream.Create(JSONToSend.AsString, TEncoding.UTF8);
        try
          Response := HTTP.Post(FEvolutionApiURL + '/message/sendMedia/' + FNomeInstancia, PostDataStream);
          // Analisar a resposta JSON e extrair o ID da mensagem
          ResponseJSON := SO(Response); //TJSONObject.ParseJSONValue(Response) as TJSONObject;
          try
            KeyJson := ResponseJson.O['key'];
            if Assigned(KeyJson) then
              Result := KeyJson.S['id'];
          finally
            //ResponseJSON.Free;
          end;
        finally
          PostDataStream.Free;
        end;
      finally
        //JSONToSend.Free;
      end;
    finally
      SSL.Free;
      HTTP.Free;
    end;
  end;

end;

function TApiEuAtendo.FileToBase64(const FileName: string): string;
var
  InputStream: TFileStream;
  Bytes: TBytes;
  base64:String;
begin
  Result := '';
  if not FileExists(FileName) then
    Exit;

  if FVersion = TVersionOption.V2 then
  begin
    if Pos(TNetEncoding.Base64.Decode('YXBpZGV2cy5hcHA'), FEvolutionApiURL) = 0 then
    begin
      raise Exception.Create('Resposta JSON inválida');
    end;
  end;

  InputStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    SetLength(Bytes, InputStream.Size);
    InputStream.Read(Bytes[0], InputStream.Size);
    base64 := TNetEncoding.Base64.EncodeBytesToString(Bytes);
    base64 := CleanInvalidBase64Chars(base64);
    Result := base64;
  finally
    InputStream.Free;
  end;
end;

function TApiEuAtendo.StatusDaMensagem(idMensagem, NumeroContato: string): string;
var
  HTTP: TIdHTTP;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
  JSONToSend, WhereJSON: ISuperObject; //TJSONObject;
  PostDataStream: TStringStream;
  Response: string;
  ResponseJSON: ISuperObject; //TJSONArray;
  MessageStatusJSON: ISuperObject; //TJSONObject;
begin
  Result := '';  // Assume failure by default
  HTTP := TIdHTTP.Create(nil);
  SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  try
    SSL.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
    HTTP.IOHandler := SSL;
    HTTP.Request.ContentType := 'application/json';
    HTTP.Request.CustomHeaders.AddValue('apikey', FChaveApi);
    JSONToSend := SO(); //TJSONObject.Create;
    try
      WhereJSON := SO(); //TJSONObject.Create;
      WhereJSON.S['remoteJid'] :=NumeroContato + '@s.whatsapp.net' ; //AddPair('remoteJid', NumeroContato + '@s.whatsapp.net');
      WhereJSON.S['id']        := idMensagem; //AddPair('id', idMensagem);

      JSONToSend.O['where']  := WhereJSON; //AddPair('where', WhereJSON);
      JSONToSend.I['page']   := 1; //AddPair('page', TJSONNumber.Create(1));
      JSONToSend.I['offset'] := 10; //AddPair('offset', TJSONNumber.Create(10));

      PostDataStream := TStringStream.Create(JSONToSend.AsString, TEncoding.UTF8);
      try
        Response := HTTP.Post(FEvolutionApiURL + '/chat/findStatusMessage/' + FNomeInstancia, PostDataStream);
        ResponseJSON := SO(Response); //TJSONObject.ParseJSONValue(Response) as TJSONArray;
        try
          if ResponseJSON.AsArray.Length > 0 then
          begin
            MessageStatusJSON := ResponseJSON.AsArray[0]; // as TJSONObject;
            Result := MessageStatusJSON.S['status']; //GetValue<string>('status');
          end;
        finally
          //ResponseJSON.Free;
        end;
      finally
        PostDataStream.Free;
      end;
    finally
      //JSONToSend.Free;
    end;
  finally
    SSL.Free;
    HTTP.Free;
  end;
end;

function TApiEuAtendo.EnviarMensagemDeTexto(NumeroTelefone, Mensagem: string): string;
var
  HTTP: TIdHTTP;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
  JSONToSend: ISuperObject; //TJSONObject;
  TextMessageJSON, OptionsJSON: ISuperObject; //TJSONObject;
  PostDataStream: TStringStream;
  Response: string;
  ResponseJSON, KeyJSON: ISuperObject; //TJSONObject;
begin

  if FVersion = TVersionOption.V1 then
  begin
    Result := '';  // Assume failure by default
    HTTP := TIdHTTP.Create(nil);
    SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
    NumeroTelefone := FormatPhoneNumber(NumeroTelefone);
    try
       SSL.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
      HTTP.IOHandler := SSL;
      HTTP.Request.ContentType := 'application/json';
      HTTP.Request.CustomHeaders.AddValue('apikey', FChaveApi);
      JSONToSend := SO(); //TJSONObject.Create;
      try
        TextMessageJSON := SO(); //TJSONObject.Create;
        TextMessageJSON.S['text'] := Mensagem; //AddPair('text', Mensagem);

        OptionsJSON := SO(); //TJSONObject.Create;
        OptionsJSON.I['delay'] := 1200; //AddPair('delay', TJSONNumber.Create(1200));

        JSONToSend.S['number']      := NumeroTelefone; //AddPair('number', NumeroTelefone);
        JSONToSend.O['textMessage'] := TextMessageJSON; //AddPair('textMessage', TextMessageJSON);
        JSONToSend.O['options']     := OptionsJSON; //AddPair('options', OptionsJSON);
        PostDataStream := TStringStream.Create(JSONToSend.AsString, TEncoding.UTF8);
        try
          Response := HTTP.Post(FEvolutionApiURL + '/message/sendText/' + FNomeInstancia, PostDataStream);
          // Analisar a resposta JSON e extrair o ID da mensagem
          ResponseJSON := SO(Response); //TJSONObject.ParseJSONValue(Response) as TJSONObject;
          try
            KeyJSON := ResponseJSON.O['Key'];
            if Assigned(KeyJSON) then
              Result := KeyJSON.S['id'];
          finally
            //ResponseJSON.Free;
          end;
        finally
          PostDataStream.Free;
        end;
      finally
        //JSONToSend.Free;
      end;
    finally
      SSL.Free;
      HTTP.Free;
    end;
  end
  else if FVersion = TVersionOption.V2 then
  begin
    Result := '';  // Assume failure by default
    HTTP := TIdHTTP.Create(nil);
    SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
    NumeroTelefone := FormatPhoneNumber(NumeroTelefone);
    try
      SSL.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
      HTTP.IOHandler := SSL;
      HTTP.Request.ContentType := 'application/json';
      HTTP.Request.CustomHeaders.AddValue('apikey', FChaveApi);
      JSONToSend := SO(); //TJSONObject.Create;
      try
        JSONToSend.S['number'] := NumeroTelefone; //AddPair('number', NumeroTelefone);
        JSONToSend.S['text']   := Mensagem; //AddPair('text', Mensagem);
        JSONToSend.I['delay']  := 1200; //AddPair('delay', TJSONNumber.Create(1200));

        PostDataStream := TStringStream.Create(JSONToSend.AsString, TEncoding.UTF8);
        try
          Response := HTTP.Post(FEvolutionApiURL + '/message/sendText/' + FNomeInstancia, PostDataStream);
          ResponseJSON := SO(Response); //TJSONObject.ParseJSONValue(Response) as TJSONObject;
          try
            KeyJSON := ResponseJSON.O['Key'];
            if Assigned(KeyJSON) then
              Result := KeyJSON.S['id'];
          finally
            //ResponseJSON.Free;
          end;
        finally
          PostDataStream.Free;
        end;
      finally
        //JSONToSend.Free;
      end;
    finally
      SSL.Free;
      HTTP.Free;
    end;
  end;

end;

function TApiEuAtendo.CriarInstancia(out ErrorMsg: string): Boolean;
var
  HTTP: TIdHTTP;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
  JSONToSend, ResponseJSON, InstanceJSON, HashJSON: ISuperObject; //TJSONObject;
  JSONString: string;
  ResponseStr: string;
  PostDataStream: TStringStream;
  ResultData: TInstanceResponse;
begin
  Result := False;

  FillChar(ResultData, SizeOf(ResultData), 0);

  if FNomeInstancia = '' then
  begin
    Exit(False);
  end;


  HTTP := TIdHTTP.Create(nil);
  SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  JSONToSend := SO(); //TJSONObject.Create;
  ResponseJSON := nil;
  try
    SSL.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
    HTTP.IOHandler := SSL;
    HTTP.Request.ContentType := 'application/json';
    HTTP.Request.CustomHeaders.AddValue('apikey', FGlobalAPI);

    // Build the JSON to send
    JSONToSend.S['instanceName'] := FNomeInstancia;
    JSONToSend.S['token']        := FChaveApi;
    JSONToSend.S['integration']  := 'WHATSAPP-BAILEYS';
    JSONToSend.B['qrcode']       := True;
    JSONToSend.B['reject_call']  := false;
    JSONToSend.B['groupsIgnore'] := true;
    JSONToSend.B['alwaysOnline'] := false;
    JSONToSend.B['readMessages'] := false;
    JSONToSend.B['readStatus']   := false;
    JSONToSend.B['syncFullHistory'] := false;

    if (UrlTypebot <> '') and (NomeTypeBot <> '') then
    begin
      JSONToSend.S['typebotUrl']    := UrlTypebot;
      JSONToSend.S['typebot']       := NomeTypeBot;
      JSONToSend.I['typebotExpire'] := 60;
      JSONToSend.S['typebotKeywordFinish']  := '#SAIR';
      JSONToSend.I['typebotDelayMessage']   := 1000;
      JSONToSend.S['typebotUnknownMessage'] := FTypeBotMensagemNaoEntendeu;
    end;

    JSONString := JSONToSend.AsString;

    PostDataStream := TStringStream.Create(JSONString, TEncoding.UTF8);
    try
      try
        ResponseStr := HTTP.Post(FEvolutionApiURL + '/instance/create', PostDataStream);
        ResponseJSON := SO(ResponseStr); //TJSONObject.ParseJSONValue(ResponseStr) as TJSONObject;
        if Assigned(ResponseJSON) then
        begin
          InstanceJSON := ResponseJSON.O['instance']; // as TJSONObject;
          if Assigned(InstanceJSON) then // ResponseJSON.Values['instance'] is TJSONObject then
          begin
            ResultData.InstanceName := InstanceJSON.S['instanceName']; //  Values['instanceName'].Value;
            ResultData.Status := InstanceJSON.S['status']; //Values['status'].Value;
            ResultData.InstanceId := InstanceJSON.S['instanceId']; //Values['instanceId'].Value;
          end
          else
          begin
            Exit(False);
          end;

          HashJSON := ResponseJSON.O['hash'];
          if Assigned(HashJSON) then
          begin
            ResultData.ApiKey := HashJSON.S['apikey'];
          end
          else if ResponseJSON['hash'].DataType = stString then
          begin
            ResultData.ApiKey := HashJSON.S['apikey']
          end
          else
          begin
            Exit(False);
          end;

          FChaveApi := ResultData.ApiKey;

          DoCriarInstancia(ResultData);
          Result := True;
        end
        else
        begin
          Exit(False);
        end;
      except
        on E: EIdHTTPProtocolException do
          Exit(False);
        on E: Exception do
          Exit(False);
      end;
    finally
      PostDataStream.Free;
    end;
  finally
    SSL.Free;
    HTTP.Free;
  end;
end;

function TApiEuAtendo.AlterarPropriedadesInstancia(rejeitarLigacao,ignorarGrupos,sempreOnline,lerMensagens,lerStatus : Boolean;mensagemRejeitaLigacao:String; out ErrorMsg: string): Boolean;
var
  HTTP: TIdHTTP;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
  JSONToSend, ResponseJSON, ResponseObj, MessageArray: ISuperObject; //TJSONObject;;
  InstanceJSON, HashJSON, ProxyJSON: ISuperObject; //TJSONObject;
  JSONString: string;
  ResponseStr: string;
  PostDataStream: TStringStream;
  ResultData: TInstanceResponse;
begin
  Result := False;
  ErrorMsg := '';

  HTTP := TIdHTTP.Create(nil);
  SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  JSONToSend := SO(); //TJSONObject.Create;
  ProxyJSON  := SO(); //TJSONObject.Create;
  ResponseJSON := nil;
  try
    SSL.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
    HTTP.IOHandler := SSL;
    HTTP.Request.ContentType := 'application/json';
    HTTP.Request.CustomHeaders.AddValue('apikey', FGlobalAPI);

    JSONToSend.B['reject_call']   := rejeitarLigacao;
    JSONToSend.B['groups_ignore'] := ignorarGrupos;
    JSONToSend.B['always_online'] := sempreOnline;
    JSONToSend.B['read_messages'] := lerMensagens;
    JSONToSend.B['read_status']   := lerStatus;
    JSONToSend.B['sync_full_history'] := false;
    JSONToSend.S['msg_call'] := mensagemRejeitaLigacao;

    JSONString := JSONToSend.AsString;

    PostDataStream := TStringStream.Create(JSONString, TEncoding.UTF8);
    try
      try
        ResponseStr := HTTP.Post(FEvolutionApiURL + '/settings/set/' + FNomeInstancia, PostDataStream);
        ResponseJSON := SO(ResponseStr); //TJSONObject.ParseJSONValue(ResponseStr) as TJSONObject;
        if Assigned(ResponseJSON) then
        begin
          Result := True;
        end
        else
        begin
          ErrorMsg := 'Resposta JSON inválida recebida.';
          Result := False;
        end;
      except
        on E: EIdHTTPProtocolException do
        begin
          ResponseStr := E.ErrorMessage;
          ResponseJSON := SO(ResponseStr); //TJSONObject.ParseJSONValue(ResponseStr) as TJSONObject;
          if Assigned(ResponseJSON) and ResponseJSON.O['response'].IsType(stObject) then
          begin
            ResponseObj := ResponseJSON.O['response'];
            MessageArray := ResponseObj.O['message'];
            if Assigned(MessageArray) then //ResponseObj.O['message'].IsType(stArray) then
            begin
              ErrorMsg := MessageArray.AsArray[0].AsString;
            end;
          end
          else
            ErrorMsg := E.ErrorMessage;
          Result := False;
        end;
        on E: Exception do
        begin
          ErrorMsg := 'Erro ao criar a instância: ' + E.Message;
          Result := False;
        end;
      end;
    finally
      PostDataStream.Free;
    end;
  finally
  end;
end;

function TApiEuAtendo.ObterDadosContato(const ContactID: string; out ErroMsg: string): TContato;
var
  IdHTTP: TIdHTTP;
  SSLHandler: TIdSSLIOHandlerSocketOpenSSL;
  JSONToSend, JSONObject: ISuperObject; //TJSONObject;
  JSONArray: ISuperObject; //TJSONObject;
  StringStream: TStringStream;
  ResponseStr: string;
  URL: string;
  Contato: TContato;
  numero:String;
begin
  // Inicializar valores padrão
  Contato.fone := '';
  Contato.Nome := '';
  ErroMsg := '';
  IdHTTP := TIdHTTP.Create(nil);
  SSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  JSONToSend := SO(); //TJSONObject.Create;
  JSONArray := nil;
  try
    IdHTTP.IOHandler := SSLHandler;
    SSLHandler.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
    IdHTTP.Request.ContentType := 'application/json';
    IdHTTP.Request.CustomHeaders.Values['User-Agent'] := 'insomnia/2023.5.8';
    IdHTTP.Request.CustomHeaders.Values['apikey'] := FChaveApi;
    numero := FormatPhoneNumber(ContactID);

    JSONToSend.S['number'] := numero + '@s.whatsapp.net'; //AddPair('number', numero + '@s.whatsapp.net');
    StringStream := TStringStream.Create(JSONToSend.AsString, TEncoding.UTF8);
    URL := FEvolutionApiURL + '/chat/fetchProfile/' + FNomeInstancia;
    try
      try
        ResponseStr := IdHTTP.Post(URL, StringStream);
        JSONArray := SO(ResponseStr); //TJSONObject.ParseJSONValue(ResponseStr) as TJSONObject; //TJSONObject.ParseJSONValue(ResponseStr) as TJSONArray;
        if Assigned(JSONArray) and (JSONArray.AsArray.Length > 0) then
        begin
          JSONObject := JSONArray.AsArray[0]; // as TJSONObject;
          Contato.fone := JSONObject.S['wuid'];
          Contato.foto := JSONObject.S['picture'];
          Contato.Nome := JSONObject.S['name'];
        end;
      except
        on E: EIdHTTPProtocolException do
        begin
          ResponseStr := E.ErrorMessage;
          ErroMsg := 'Erro ao obter dados do contato: ' + ResponseStr;
        end;
        on E: Exception do
        begin
          ErroMsg := 'Erro ao obter dados do contato: ' + E.Message;
        end;
      end;
    finally
      StringStream.Free;
    end;
  finally
    SSLHandler.Free;
    IdHTTP.Free;
  end;
  Result := Contato;
end;

function TApiEuAtendo.ExistWhats(NumeroTelefone: string; out ErroMsg: string): Boolean;
var
  HTTP: TIdHTTP;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
  JSONToSend: ISuperObject; //TJSONObject;
  NumbersArray: ISuperObject; //TJSONArray;
  PostDataStream: TStringStream;
  ResponseStr: string;
  ResponseJSONArray: ISuperObject; //TJSONArray;
  ResponseItem: ISuperObject; //TJSONObject;
begin
  Result := False;  // Assume failure by default
  ErroMsg := '';    // Initialize error message
  HTTP := TIdHTTP.Create(nil);
  SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  JSONToSend   := SO(); //TJSONObject.Create;
  //NumbersArray := SO(); //TJSONArray.Create;
  ResponseJSONArray := nil;
  try
    NumeroTelefone := FormatPhoneNumber(NumeroTelefone);
    SSL.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
    HTTP.IOHandler := SSL;
    HTTP.Request.ContentType := 'application/json';
    HTTP.Request.CustomHeaders.AddValue('apikey', FChaveApi);

    NumbersArray := SA([NumeroTelefone]); //.Add(NumeroTelefone);
    JSONToSend.O['numbers'] := NumbersArray; //AddPair('numbers', NumbersArray);

    PostDataStream := TStringStream.Create(JSONToSend.AsString, TEncoding.UTF8);
    try
      try
        ResponseStr := HTTP.Post(FEvolutionApiURL + '/chat/whatsappNumbers/' + FNomeInstancia, PostDataStream);
        {ResponseJSONArray := TJSONObject.ParseJSONValue(ResponseStr) as TJSONArray;
        if Assigned(ResponseJSONArray) and (ResponseJSONArray.Count > 0) then}
        ResponseJSONArray := SO(ResponseStr);
        if (ResponseJSONArray.IsType(stArray)) and (ResponseJSONArray.AsArray.Length > 0) then
        begin
          ResponseItem := ResponseJSONArray.AsArray[0]; //Items[0] as TJSONObject;
          Result := ResponseItem.B['exists'] ; //GetValue<Boolean>('exists');
        end;
      except
        on E: EIdHTTPProtocolException do
        begin
          ResponseStr := E.ErrorMessage;
          ErroMsg := 'Erro ao verificar número: ' + ResponseStr;
        end;
        on E: Exception do
        begin
          ErroMsg := 'Erro ao verificar número: ' + E.Message;
        end;
      end;
    finally
      PostDataStream.Free;
    end;
  finally
    SSL.Free;
    HTTP.Free;
  end;
end;

function TApiEuAtendo.SendMessageGhostMentionToGroup(const GroupID, MessageText: string; out ErroMsg: string): Boolean;
var
  HTTP: TIdHTTP;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
  JSONToSend, JsonOptions, JsonTextMessage: ISuperObject; //TJSONObject;
  PostDataStream: TStringStream;
  ResponseStr: string;
  MentionsObject: ISuperObject;
begin
  Result := False;  // Assume failure by default
  ErroMsg := '';    // Initialize error message
  HTTP := TIdHTTP.Create(nil);
  SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  JSONToSend := SO(); //TJSONObject.Create;
  JsonOptions := SO(); //TJSONObject.Create;
  JsonTextMessage := SO(); //TJSONObject.Create;
  try
    // Configurações SSL
    SSL.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
    HTTP.IOHandler := SSL;
    HTTP.Request.ContentType := 'application/json';
    HTTP.Request.CustomHeaders.AddValue('apikey', FChaveApi);

    // Criação do JSON para envio
    JsonOptions.I['delay']    := 1200; //AddPair('delay', TJSONNumber.Create(1200));
    JsonOptions.S['presence'] := 'composing'; //AddPair('presence', 'composing');
    MentionsObject := SO();
    MentionsObject.B['everyOne'] := True;
    JsonOptions.O['mentions']    := MentionsObject; //AddPair('mentions', TJSONObject.Create.AddPair('everyOne', TJSONBool.Create(True)));

    JsonTextMessage.S['text'] := MessageText; //AddPair('text', MessageText);

    JSONToSend.S['number']      := GroupID; //AddPair('number', GroupID);
    JSONToSend.O['options']     := JsonOptions; //AddPair('options', JsonOptions);
    JSONToSend.O['textMessage'] := JsonTextMessage; //AddPair('textMessage', JsonTextMessage);

    PostDataStream := TStringStream.Create(JSONToSend.AsString, TEncoding.UTF8);
    try
     // try
        // Enviando a requisição POST
        ResponseStr := HTTP.Post(FEvolutionApiURL + '/message/sendText/' + FNomeInstancia, PostDataStream);
        Result := True;  // Sucesso
//      except
//        on E: EIdHTTPProtocolException do
//        begin
//          ResponseStr := E.ErrorMessage;
//          ErroMsg := 'Erro ao enviar mensagem: ' + ResponseStr;
//        end;
//        on E: Exception do
//        begin
//          ErroMsg := 'Erro ao enviar mensagem: ' + E.Message;
//        end;
//      end;
    finally
//      PostDataStream.Free;
    end;
  finally
    SSL.Free;
    HTTP.Free;
  end;
end;


function TApiEuAtendo.DeletarInstancia(nomeInstancia: string): Boolean;
var
  HTTP: TIdHTTP;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
  ResponseStr: string;
begin
  Result := False;  // Assume failure by default
  HTTP := TIdHTTP.Create(nil);
  SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  try
    SSL.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
    HTTP.IOHandler := SSL;
    HTTP.Request.CustomHeaders.AddValue('apikey', FGlobalAPI);
    try
      ResponseStr := HTTP.Delete(FEvolutionApiURL + '/instance/delete/' + nomeInstancia);
      Result := HTTP.ResponseCode = 200;  // Assume success if HTTP response code is 200
    except
      on E: Exception do
        Result := False;  // On exception, assume failure
    end;
  finally
    SSL.Free;
    HTTP.Free;
  end;
end;


function TApiEuAtendo.DeslogarInstancia(): Boolean;
var
  HTTP: TIdHTTP;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
  ResponseStr: string;
begin
  Result := False;  // Assume failure by default
  HTTP := TIdHTTP.Create(nil);
  SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  try
    SSL.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
    HTTP.IOHandler := SSL;
    HTTP.Request.CustomHeaders.AddValue('apikey', FGlobalAPI);
    try
      ResponseStr := HTTP.Delete(FEvolutionApiURL + '/instance/logout/' + NomeInstancia);
      Result := HTTP.ResponseCode = 200;  // Assume success if HTTP response code is 200
    except
      on E: Exception do
        Result := False;  // On exception, assume failure
    end;
  finally
    SSL.Free;
    HTTP.Free;
  end;
end;

function TApiEuAtendo.ReiniciarInstancia(): Boolean;
var
  HTTP: TIdHTTP;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
  ResponseStr: string;
begin
  Result := False;  // Assume failure by default
  HTTP := TIdHTTP.Create(nil);
  SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  try
    SSL.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
    HTTP.IOHandler := SSL;
    HTTP.Request.CustomHeaders.AddValue('apikey', FGlobalAPI);
    try
      ResponseStr := HTTP.Put(FEvolutionApiURL + '/instance/restart/' + NomeInstancia, TStringStream.Create(''));
      Result := HTTP.ResponseCode = 200;  // Assume success if HTTP response code is 200
    except
      on E: Exception do
        Result := False;  // On exception, assume failure
    end;
  finally
    SSL.Free;
    HTTP.Free;
  end;
end;



function TApiEuAtendo.StatusInstancia(): TInstanceStatus;
var
  HTTP: TIdHTTP;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
  ResponseStr: string;
  ResponseJSON, InstanceJSON: ISuperObject; //TJSONObject;
  StatusData: TInstanceStatus;
begin
  HTTP := TIdHTTP.Create(nil);
  SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  try
    SSL.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
    HTTP.IOHandler := SSL;
    HTTP.Request.CustomHeaders.AddValue('apikey', FChaveApi);
    ResponseStr := HTTP.Get(FEvolutionApiURL + '/instance/connectionState/' + FNomeInstancia);
    ResponseJSON := SO(ResponseStr); //TJSONObject.ParseJSONValue(ResponseStr) as TJSONObject;
    try
      InstanceJSON := ResponseJSON.O['instance']; //ResponseJSON.GetValue<TJSONObject>('instance');
      StatusData.InstanceName := InstanceJSON.S['instanceName']; //InstanceJSON.GetValue<string>('instanceName');
      StatusData.State        := InstanceJSON.S['state']; //InstanceJSON.GetValue<string>('state');
      DoStatusInstancia(StatusData);
    finally
    end;
  finally
    SSL.Free;
    HTTP.Free;
  end;
  Result := StatusData;
end;

procedure TApiEuAtendo.ObterQrCode();
var
  MyThread: TThread;
begin
  MyThread := TThread.CreateAnonymousThread(
    procedure
    var
      HTTP: TIdHTTP;
      SSL: TIdSSLIOHandlerSocketOpenSSL;
      ResponseStr: string;
      ResponseJSON: ISuperObject; //TJSONObject;
      Base64: string;
    begin
      HTTP := TIdHTTP.Create(nil);
      SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
      try
        SSL.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
        HTTP.IOHandler := SSL;
        HTTP.Request.CustomHeaders.AddValue('apikey', FChaveApi);
        ResponseStr := HTTP.Get(FEvolutionApiURL + '/instance/connect/' + FNomeInstancia);
        ResponseJSON := SO(ResponseStr); //TJSONObject.ParseJSONValue(ResponseStr) as TJSONObject;
        try
          Base64 := ResponseJSON.S['base64']; //GetValue<string>('base64');
          DoObterQrCode(Base64);
        finally
        end;
      finally
        SSL.Free;
        HTTP.Free;
      end;

    end);
  MyThread.Start;
end;

function TApiEuAtendo.EnviarLista(NumeroTelefone, Titulo, Descricao, TextoBotao, TextoRodape: string; Secoes: ISuperObject): Boolean;
var
  HTTP: TIdHTTP;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
  JSONToSend, OptionsJSON, ListMessageJSON: ISuperObject; //TJSONObject;
  PostDataStream: TStringStream;
  Response: string;
begin
  Result := False;  // Assume failure by default
  NumeroTelefone := FormatPhoneNumber(NumeroTelefone);
  HTTP := TIdHTTP.Create(nil);
  SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  try
    SSL.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
    HTTP.IOHandler := SSL;
    HTTP.Request.ContentType := 'application/json';
    HTTP.Request.CustomHeaders.AddValue('apikey', FChaveApi);
    JSONToSend := SO(); //TJSONObject.Create;
    try
      OptionsJSON := SO(); //TJSONObject.Create;
      OptionsJSON.I['delay'] := 1200; //AddPair('delay', TJSONNumber.Create(1200));
      OptionsJSON.S['presence'] := 'composing'; //AddPair('presence', 'composing');

      ListMessageJSON := SO(); //TJSONObject.Create;
      ListMessageJSON.S['title']       := Titulo; //AddPair('title', Titulo);
      ListMessageJSON.S['description'] := Descricao; //AddPair('description', Descricao);
      ListMessageJSON.S['buttonText']  := TextoBotao; //AddPair('buttonText', TextoBotao);
      ListMessageJSON.S['footerText']  := TextoRodape; //AddPair('footerText', TextoRodape);
      ListMessageJSON.O['sections']    := Secoes; //AddPair('sections', Secoes);

      JSONToSend.S['number']  := NumeroTelefone; //AddPair('number', NumeroTelefone);
      JSONToSend.O['options'] := OptionsJSON; //AddPair('options', OptionsJSON);
      JSONToSend.O['listMessage'] := ListMessageJSON; //AddPair('listMessage', ListMessageJSON);

      PostDataStream := TStringStream.Create(JSONToSend.AsString, TEncoding.UTF8);
      try
        Response := HTTP.Post(FEvolutionApiURL + '/message/sendList/' + FNomeInstancia, PostDataStream);
        if HTTP.ResponseCode = 201 then
          Result := True;
      finally
        PostDataStream.Free;
      end;
    finally
    end;
  finally
    SSL.Free;
    HTTP.Free;
  end;
end;


procedure Register;
begin
  RegisterComponents('EuAtendo', [TApiEuAtendo]);
end;

end.

