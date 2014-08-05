import io.vertx.ceylon.stream { ReadStream, WriteStream, wrapReadStream, wrapWriteStream }
import ceylon.promise { Promise }
import org.vertx.java.core.buffer { Buffer }
import org.vertx.java.core.file { AsyncFile_=AsyncFile }
import java.lang {
  Void_=Void
}
import io.vertx.ceylon.util {
  AsyncResultPromise
}

"""Represents a file on the file-system which can be read from, or written to asynchronously.
   
   This class also provides a [[readStream]] and a [[writeStream]]. This allows the data to be pumped to and from
   other streams, e.g. an [[io.vertx.ceylon.http::HttpClientRequest]] instance using the [[io.vertx.ceylon.stream::Pump]]
   class.
   
   Instances of AsyncFile are not thread-safe"""
shared class AsyncFile(String path, AsyncFile_ delegate) {
  
  variable ReadStream? readStream_ = null;
  variable WriteStream? writeStream_ = null;
  
  shared ReadStream readStream() {
    if (exists ret = readStream_) {
      return ret;
    } else {
      value ret = wrapReadStream(delegate);
      readStream_ = ret;
      return ret;
    }
  }
  
  shared WriteStream writeStream() {
    if (exists ret = writeStream_) {
      return ret;
    } else {
      value ret = wrapWriteStream(delegate);
      writeStream_ = ret;
      return ret;
    }
  }
  
  "Close the file. The actual close happens asynchronously. The returned promise will be
   resolved when the close is complete, or an error occurs."
  shared Promise<Null> close() {
    value result = AsyncResultPromise<Null, Void_>((Void_ v) => null);
    delegate.close(result);
    return result.promise;
  }
  
  """Write a [[buffer]] to the file at position [[position]] in the file, asynchronously.
     If [[position]] lies outside of the current size of the file, the file will be enlarged to encompass it.
     
     When multiple writes are invoked on the same file there are no guarantees as to order in which
     those writes actually occur.
     
     The returned promise will be resolved when the write is complete, or if an error occurs."""
  shared Promise<Null> write(Buffer buffer, Integer position) {
    value result = AsyncResultPromise<Null, Void_>((Void_ v) => null);
    delegate.write(buffer, position, result);
    return result.promise;
  }
  
  """Reads [[length]] bytes of data from the file at position [[position]] in the file, asynchronously.
     
     The read data will be written into the specified [[buffer]] at position [[offset]].
     
     If data is read past the end of the file then zero bytes will be read.
     
     When multiple reads are invoked on the same file there are no guarantees as to order in which those
     reads actually occur.
     
     The returned promise will be resolved when the close is complete, or if an error occurs."""
  shared Promise<Buffer> read(Buffer buffer, Integer offset, Integer position, Integer length) {
    value result = AsyncResultPromise<Buffer, Buffer>((Buffer v) => v);
    delegate.read(buffer, offset, position, length, result);
    return result.promise;
  }
  
  """Flush any writes made to this file to underlying persistent storage.
     
     If the file was opened with `flush` set to `true` then calling this method will have no effect.
     
     The actual flush will happen asynchronously.
     
     The returned promise will be resolved when the flush is complete or if an error occurs"""
  shared Promise<Null> flush() {
    value result = AsyncResultPromise<Null, Void_>((Void_ v) => null);
    delegate.flush(result);
    return result.promise;
  }
  
  shared actual String string {
    return path;
  }
}