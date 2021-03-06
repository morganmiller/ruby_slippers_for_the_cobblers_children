package ruby;

import ruby.ds.*;
import ruby.ds.Objects;


// For now, this will become a god class,
// as it evolves, pay attention to its responsibilities so we can extract them into their own objects.
class World {
  private var world:ruby.ds.World;

  public function new(world:ruby.ds.World) {
    this.world       = world;
    this.interpreter = new ruby.Interpreter(this, world);
  }

  public function intern(name:String):RSymbol {
    if(!world.symbols.exists(name)) {
      var symbol = new RSymbol();
      symbol.name  = name;
      symbol.klass = world.symbolClass;
      symbol.ivars = new InternalMap();
      world.symbols.set(name, symbol);
    }
    return world.symbols.get(name);
  }

  public function castClass(klass:RObject):RClass {
    var tmp:Dynamic = klass;
    var typedClass:RClass = tmp;
    // or should this return null if its not a class?
    if(typedClass.imeths == null) throw("Can't cast this, it's not a class: " + sinspect(klass));
    return typedClass;
  }

  public function stringLiteral(value:String):RString {
    var str:RString = new RString();
    str.klass = stringClass;
    str.ivars = new InternalMap();
    str.value = value;

    objectSpace.push(str);
    return str;
  }

  public function eachObject(klass:RClass):Array<RObject> {
    var selected = [];
    for(obj in world.objectSpace)
      if(obj.klass == klass)
        selected.push(obj);
    return selected;
  }


  // s b/c static and instance functions can't have the same name -.^
  static public function sinspect(obj:RObject):String {
    if(obj == null) return 'Haxe null';

    var klass = switch(obj) {
      case {klass: k}: k;
      case _: throw "no kass here: " + obj;
    }

    if(klass.name == 'Class') {
      var tmp:Dynamic = obj;
      var objClass:RClass = tmp;
      return objClass.name;
    } else if(klass.name == 'String') {
      var tmp:Dynamic = obj;
      var objString:RString = tmp;
      return '"'+objString.value+'"'; // will do for now
    } else if(klass.name == 'Symbol') {
      var tmp:Dynamic = obj;
      var objSym:RSymbol = tmp;
      return ':'+objSym.name; // will do for now
    } else {
      // throw("NO INSPECTION FOR: " + obj.klass.name);
      return "#<" + obj.klass.name + ">";
    }
  }

  public function inspect():String {
    return 'RB(THE WORLD!!)';
  }

  // faux attributes
  public var objectSpace(get, never):Array<RObject>;  // do I actually want to expose this directly?
  function get_objectSpace() return world.objectSpace;

  // Objects special enough to be properties
  public var              main(    get, never):RObject;
  public var           rubyNil(    get, never):RObject;
  public var         rubyFalse(    get, never):RObject;
  public var          rubyTrue(    get, never):RObject;
  public var        classClass(    get, never):RClass;
  public var       stringClass(    get, never):RClass;
  public var       symbolClass(    get, never):RClass;
  public var       moduleClass(    get, never):RClass;
  public var       objectClass(    get, never):RClass;
  public var  basicObjectClass(    get, never):RClass;
  public var   toplevelBinding(    get, never):RBinding;
  public var toplevelNamespace(    get, never):RClass;
  public var       interpreter(default,  null):ruby.Interpreter;
  public var   printedToStdout(    get,   set):Array<String>;

  function              get_main() return world.main;
  function           get_rubyNil() return world.rubyNil;
  function         get_rubyFalse() return world.rubyFalse;
  function          get_rubyTrue() return world.rubyTrue;
  function        get_classClass() return world.klassClass;
  function       get_stringClass() return world.stringClass;
  function       get_symbolClass() return world.symbolClass;
  function       get_moduleClass() return world.moduleClass;
  function       get_objectClass() return world.objectClass;
  function  get_basicObjectClass() return world.basicObjectClass;
  function   get_toplevelBinding() return world.toplevelBinding;
  function get_toplevelNamespace() return world.toplevelNamespace;
  function   get_printedToStdout() return world.printedToStdout;
  function   set_printedToStdout(strs) return world.printedToStdout = strs;
}
