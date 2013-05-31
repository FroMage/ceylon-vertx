import ceylon.test { ... }
import ceylon.collection { ... }
import vietj.promises { ... }

class ExceptionCollector() {
  shared LinkedList<Exception> collected = LinkedList<Exception>();
  shared Exception add(Exception e) {
    collected.add(e);
    return e;
  }
}

void run() {

  suite("vietj.promises", "Deferred" -> deferredTests);
  suite("vietj.promises", "Promise" -> promiseTests);
  suite("vietj.then", "Then method" -> thenTests);
  suite("vietj.resolution", "Resolution Procedure" -> resolutionTests);
  suite("vietj.conjonction", "Conjonction" -> conjonctionTests);

  useCases();

}

void useCases() {

  void testNoFulfilledWithCasting() {
    Deferred<String> d = Deferred<String>();
    LinkedList<String> collected = LinkedList<String>();
    void foo(String s) {
      collected.add(s);
    }
    d.promise.then_<String>().then_(foo);
    d.resolve("foo");
    assertEquals { expected = {"foo"}; actual = collected; };
  }

  void testNoFulfilledWithNoCasting() {
    Deferred<String> d = Deferred<String>();
    LinkedList<Exception> collected = LinkedList<Exception>();
    void foo(Exception e) {
      collected.add(e);
    }
    d.promise.then_<Boolean>().then_{onRejected = foo;};
    d.resolve("foo");
    assertEquals { expected = 1; actual = collected.size; };
  }

  void testReject() {
    LinkedList<Integer> done = LinkedList<Integer>();
    Deferred<Integer> d = Deferred<Integer>();
    variable Exception? found = null;
    Exception e(Exception r) {
      found = r;
      return r;
    }
    d.promise.then_(done.add, e);
    Exception ee = Exception();
    d.reject(ee);
    assertEquals { expected = ee; actual = found; };
    assertEquals { expected = {}; actual = done; };
  }

  void testFail() {
    LinkedList<Integer> done = LinkedList<Integer>();
    variable Exception? found = null;
    Exception cc(Exception r) {
      found = r;
      return r;
    }

    Deferred<Integer> d = Deferred<Integer>();
    Exception e = Exception();
    Integer foo(Integer i) {
      throw e;
    }
    d.promise.then_(foo).then_(done.add, cc);
    d.resolve(3);

    assertEquals { expected = e; actual = found; };
    assertEquals { expected = {}; actual = done; };
  }

  void testCatchReason() {
    LinkedList<Integer> collected = LinkedList<Integer>();
    LinkedList<Exception> exc = LinkedList<Exception>();
    Deferred<Integer> deferred = Deferred<Integer>();
    Exception e = Exception();
    Integer foo(Integer i) {
      throw e;
    }
    Integer bar(Exception e) {
      exc.add(e);
      return 4;
    }
    deferred.promise.then_(foo).then_((Integer i) => i, bar).then_(collected.add);
    deferred.resolve(3);
    assertEquals { expected = {4}; actual = collected; };
    assertEquals { expected = {e}; actual = exc; };
  }

  void testResolveWithPromise() {
    variable Integer? i = null;
    Deferred<Integer> di = Deferred<Integer>();
    String f(Integer integer) {
      i = integer;
      return integer.string;
    }
    Promise<String> p = di.promise.then_(f);
    variable String? s = null;
    Deferred<String> d = Deferred<String>();
    d.promise.then_((String string) => s = string);
    assertEquals { expected = null; actual = i; };
    assertEquals { expected = null; actual = s; };
    d.resolve(p);
    assertEquals { expected = null; actual = i; };
    assertEquals { expected = null; actual = s; };
    di.resolve(4);
    assertEquals { expected = 4; actual = i; };
    assertEquals { expected = "4"; actual = s; };
  }

  void testComposeWithPromise() {
    Deferred<Integer> d = Deferred<Integer>();
    Deferred<String> mine = Deferred<String>();
    variable Integer? a = null;
    Promise<String> f(Integer i) {
      a = i;
      return mine.promise;
    }
    Promise<String> p = d.promise.then_<String>(f);
   variable String? result = null;
    void g(String s) {
      result = s;
    }
    p.then_(g);
    assertEquals { expected = null; actual = a; };
    assertEquals { expected = null; actual = result; };
    d.resolve(4);
    assertEquals { expected = 4; actual = a; };
    assertEquals { expected = null; actual = result; };
    mine.resolve("foo");
    assertEquals { expected = 4; actual = a; };
    assertEquals { expected = "foo"; actual = result; };
  }

  testNoFulfilledWithCasting();
  testNoFulfilledWithNoCasting();
  testReject();
  testFail();
  testCatchReason();
  testResolveWithPromise();
  testComposeWithPromise();
}

