{
  This file is part of R&Q.
  Under same license
}
unit RDGlobal;
{$I ForRnQConfig.inc}
{$I NoRTTI.inc}

 { $ DEFINE RNQ_PLAYER}

interface
uses
  Classes, Messages, Types, Forms, ExtCtrls, Graphics;

{ ************ common types used for compatibility between compilers and CPU }

{$ifndef FPC} { make cross-compiler and cross-CPU types available to Delphi }
type

  /// a CPU-dependent unsigned integer type cast of a pointer / register
  // - used for 64 bits compatibility, native under Free Pascal Compiler
{$ifdef ISDELPHI2009}
  PtrUInt = cardinal; { see http://synopse.info/forum/viewtopic.php?id=136 }
{$else}
  PtrUInt = {$ifdef UNICODE}NativeUInt{$else}cardinal{$endif};
{$endif}
  /// a CPU-dependent unsigned integer type cast of a pointer of pointer
  // - used for 64 bits compatibility, native under Free Pascal Compiler
  PPtrUInt = ^PtrUInt;

  /// a CPU-dependent signed integer type cast of a pointer / register
  // - used for 64 bits compatibility, native under Free Pascal Compiler
  PtrInt = {$ifdef UNICODE}NativeInt{$else}integer{$endif};
  /// a CPU-dependent signed integer type cast of a pointer of pointer
  // - used for 64 bits compatibility, native under Free Pascal Compiler
  PPtrInt = ^PtrInt;

  /// unsigned Int64 doesn't exist under older Delphi, but is defined in FPC
  QWord = {$ifdef UNICODE}UInt64{$else}Int64{$endif};

{$ifNdef COMPILER16_UP}
//  INT_PTR = System.IntPtr;    // NativeInt;
  INT_PTR = NativeInt;
  {$EXTERNALSYM INT_PTR}
//  UINT_PTR = System.UIntPtr;  // NativeUInt;
  UINT_PTR = NativeUInt;
  UIntPtr = UINT_PTR;
  {$EXTERNALSYM UINT_PTR}
  PINT_PTR = ^INT_PTR;
  {$EXTERNALSYM PINT_PTR}
  PUINT_PTR = ^UINT_PTR;
  {$EXTERNALSYM PUINT_PTR}
{$ENDIF}

{$endif}


type
 {$IFNDEF UNICODE}
  RawByteString = AnsiString;
 {$ENDIF UNICODE}
  TPicName = AnsiString;
//  TPicName = String;
  TPicNameW = WideString;

  TStrObj = class(TObject)
   public
    str: String;
  end;
  TPStrObj = Class(TObject)
   public
    Str: PAnsiChar;
  end;

  TPUStrObj = Class(TObject)
   public
    Str: PChar;
  end;

  TRnQPntBox = class(TPaintBox)
  protected
//    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
    procedure WMEraseBkgnd(var Msg: TWmEraseBkgnd); message WM_ERASEBKGND;
  public
    constructor Create(AOwner: TComponent); override;
//    procedure PaintImages;
  end;

type
  PGPPoint = ^TGPPoint;
  TGPPoint = packed record
    X: Integer;
    Y: Integer;
  end;
  TPointDynArray = array of TGPPoint;

  function MakePoint(p2: TPoint): TGPPoint; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
//  function MakePoint(X, Y: Integer): TGPPoint; overload;

//--------------------------------------------------------------------------
// Represents a dimension in a 2D coordinate system (integer coordinates)
//--------------------------------------------------------------------------

type
  PGPSize = ^TGPSize;
  TGPSize = packed record
    Width: Integer;
    Height: Integer;
    constructor create(Width, Height: Integer);
    function asTSize: TSize;
    function ToPPI(PPI: Integer): TGPSize; OverLoad;
    function ToPPI(PPI: Integer; selfDPI: Integer): TGPSize; OverLoad;
  end;

  function MakeSize(sz2: TSize): TGPSize; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
//  function GetSize(sz1: TGPSize): TSize; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
//  function MakeSize(Width, Height: Integer): TGPSize; overload;

type
  PGPRect = ^TGPRect;
  TGPRect = packed record
      case Integer of
      0: (X, Y, Width, Height: Integer);
      1: (TopLeft : TGPPoint; size: TGPSize);
  end;
  TRectDynArray = array of TGPRect;

  function MakeRect(x, y, width, height: Integer): TGPRect; overload; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
  function MakeRect(location: TGPPoint; size: TGPSize): TGPRect; overload; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
  function MakeRect(const Rect: TRect): TGPRect; overload; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}

type
  TMsgDlgType = (mtWarning, mtError, mtInformation, mtConfirmation, mtCustom);
  TMsgDlgTypes = set of TMsgDlgType;
  TMsgDlgBtn = (mbYes, mbNo, mbOK, mbCancel, mbAbort, mbRetry, mbIgnore,
    mbAll, mbNoToAll, mbYesToAll, mbHelp, mbClose);
  TMsgDlgButtons = set of TMsgDlgBtn;


const
  CrLf           = AnsiString(#13#10);
  CrLfS          = #13#10;
//  CRLFA: AnsiString = AnsiString(#13#10);
  CRLFCRLF  = AnsiString(CRLF+CRLF);
//  CRLFCRLF: AnsiString = AnsiString(CRLF+CRLF);
//  CRLFCRLF: AnsiString = AnsiString(#13#10#13#10);
  NL = #10;
  HexChars = ['A'..'F', 'a'..'f', '0'..'9'];
  yesno: array [boolean] of AnsiString=('No','Yes');
  Def_DateTimeFormat = 'DD.MM.YYYY HH:NN:SS';
  Def_DateFormat     = 'DD.MM.YYYY';

const
  AlphaMask = $FF000000;


  GByte = 1024*1024*1024;
  MByte = 1024*1024;

  cDefaultDPI = 96;

var
//  myPath: String;
  ShellVersion: Cardinal;

const
 // Windows resourses!!!!!!!!
  PIC_EXCLAMATION                 = TPicName('exclamation');
  PIC_HAND                        = TPicName('hand');
  PIC_ASTERISK                    = TPicName('asterisk');
  PIC_QUEST                       = TPicName('question');

  function  PicName2Str(val: TPicName): String; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}

implementation
   uses
     Windows, Controls;

constructor TRnQPntBox.Create(AOwner: TComponent);
begin
  inherited;
//  ControlStyle := ControlStyle + [ csOpaque ] ;
end;

procedure TRnQPntBox.WMEraseBkgnd(var Msg: TWmEraseBkgnd);
Begin
//  inherited;
//   msg.Result := 1;
   msg.Result := LRESULT(False);
   msg.Msg := 0;
end;

  function MakePoint(p2: TPoint): TGPPoint;
  begin
    Result.X := p2.X;
    Result.Y := p2.Y;
  end;

  function MakeSize(sz2: TSize): TGPSize;
  begin
    Result.Width := sz2.cx;
    Result.Height := sz2.cy;
  end;
{
  function GetSize(sz1: TGPSize): TSize;
  begin
    Result.cx := sz1.Width;
    Result.cy := sz1.Height;
  end;
}
  constructor TGPSize.create(Width, Height: Integer);
  begin
    Self.Width := Width;
    Self.Height := Height;
  end;

  function TGPSize.asTSize: TSize;
  begin
    Result.cx := Width;
    Result.cy := Height;
  end;

  function TGPSize.ToPPI(PPI: Integer): TGPSize;
  begin
    if (PPI > 30) and (PPI <> cDefaultDPI) then
      begin
        Result.Width := MulDiv(Self.Width, PPI, cDefaultDPI);
        Result.Height := MulDiv(Self.Height, PPI, cDefaultDPI);
      end
     else
      begin
        Result.Width := Self.Width;
        Result.Height := Self.Height;
      end
  end;

  function TGPSize.ToPPI(PPI: Integer; selfDPI: Integer): TGPSize;
  var
    lDPI: Integer;
  begin
    if (selfDPI > 20) then
      lDPI := selfDPI
     else
      lDPI := cDefaultDPI;

    if (PPI > 30) and (PPI <> lDPI) then
      begin
        Result.Width := MulDiv(Self.Width, PPI, lDPI);
        Result.Height := MulDiv(Self.Height, PPI, lDPI);
      end
     else
      begin
        Result.Width := Self.Width;
        Result.Height := Self.Height;
      end
  end;

  function MakeRect(x, y, width, height: Integer): TGPRect; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
  begin
    Result.X      := x;
    Result.Y      := y;
    Result.Width  := width;
    Result.Height := height;
  end;

  function MakeRect(location: TGPPoint; size: TGPSize): TGPRect; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
  begin
//    Result.X      := location.X;
//    Result.Y      := location.Y;
    Result.TopLeft := location;
//    Result.Width  := size.Width;
//    Result.Height := size.Height;
    Result.size := size;
  end;

  function MakeRect(const Rect: TRect): TGPRect; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
  begin
    Result.X := rect.Left;
    Result.Y := Rect.Top;
    Result.Width := Rect.Right-Rect.Left;
    Result.Height:= Rect.Bottom-Rect.Top;
  end;

function  PicName2Str(val: TPicName): String; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
begin
//  if TPicName is AnsiString then
    Result := String(val);
end;

end.
