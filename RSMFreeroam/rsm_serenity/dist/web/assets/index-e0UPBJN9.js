var __defProp = Object.defineProperty;
var __defNormalProp = (obj, key, value) => key in obj ? __defProp(obj, key, { enumerable: true, configurable: true, writable: true, value }) : obj[key] = value;
var __publicField = (obj, key, value) => {
  __defNormalProp(obj, typeof key !== "symbol" ? key + "" : key, value);
  return value;
};
(function polyfill() {
  const relList = document.createElement("link").relList;
  if (relList && relList.supports && relList.supports("modulepreload")) {
    return;
  }
  for (const link of document.querySelectorAll('link[rel="modulepreload"]')) {
    processPreload(link);
  }
  new MutationObserver((mutations) => {
    for (const mutation of mutations) {
      if (mutation.type !== "childList") {
        continue;
      }
      for (const node of mutation.addedNodes) {
        if (node.tagName === "LINK" && node.rel === "modulepreload")
          processPreload(node);
      }
    }
  }).observe(document, { childList: true, subtree: true });
  function getFetchOpts(link) {
    const fetchOpts = {};
    if (link.integrity)
      fetchOpts.integrity = link.integrity;
    if (link.referrerPolicy)
      fetchOpts.referrerPolicy = link.referrerPolicy;
    if (link.crossOrigin === "use-credentials")
      fetchOpts.credentials = "include";
    else if (link.crossOrigin === "anonymous")
      fetchOpts.credentials = "omit";
    else
      fetchOpts.credentials = "same-origin";
    return fetchOpts;
  }
  function processPreload(link) {
    if (link.ep)
      return;
    link.ep = true;
    const fetchOpts = getFetchOpts(link);
    fetch(link.href, fetchOpts);
  }
})();
const vertexShaderSrc = `
  attribute vec2 a_position;
  attribute vec2 a_texcoord;
  uniform mat3 u_matrix;
  varying vec2 textureCoordinate;
  void main() {
    gl_Position = vec4(a_position, 0.0, 1.0);
    textureCoordinate = a_texcoord;
  }
`;
const fragmentShaderSrc = `
varying highp vec2 textureCoordinate;
uniform sampler2D external_texture;
void main()
{
  gl_FragColor = texture2D(external_texture, textureCoordinate);
}
`;
function attachShader(gl, program, type, src) {
  const shader = gl.createShader(type);
  if (!shader)
    return;
  gl.shaderSource(shader, src);
  gl.attachShader(program, shader);
  return shader;
}
function compileAndLinkShaders(gl, program, vs, fs) {
  gl.compileShader(vs);
  gl.compileShader(fs);
  gl.linkProgram(program);
  if (gl.getProgramParameter(program, gl.LINK_STATUS)) {
    return;
  }
  console.error("Link failed:", gl.getProgramInfoLog(program));
  console.error("vs log:", gl.getShaderInfoLog(vs));
  console.error("fs log:", gl.getShaderInfoLog(fs));
  throw new Error("Failed to compile shaders");
}
function createTexture(gl) {
  const tex = gl.createTexture();
  const texPixels = new Uint8Array([0, 0, 255, 255]);
  gl.bindTexture(gl.TEXTURE_2D, tex);
  gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, 1, 1, 0, gl.RGBA, gl.UNSIGNED_BYTE, texPixels);
  gl.texParameterf(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
  gl.texParameterf(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
  gl.texParameterf(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
  gl.texParameterf(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
  gl.texParameterf(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.MIRRORED_REPEAT);
  gl.texParameterf(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT);
  gl.texParameterf(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
  return tex;
}
function createBuffers(gl) {
  const vertexBuff = gl.createBuffer();
  gl.bindBuffer(gl.ARRAY_BUFFER, vertexBuff);
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([-1, -1, 1, -1, -1, 1, 1, 1]), gl.STATIC_DRAW);
  const texBuff = gl.createBuffer();
  gl.bindBuffer(gl.ARRAY_BUFFER, texBuff);
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([0, 0, 1, 0, 0, 1, 1, 1]), gl.STATIC_DRAW);
  return { vertexBuff, texBuff };
}
function createProgram(gl) {
  const program = gl.createProgram();
  if (!program)
    return;
  const vertexShader = attachShader(gl, program, gl.VERTEX_SHADER, vertexShaderSrc);
  if (!vertexShader)
    return;
  const fragmentShader = attachShader(gl, program, gl.FRAGMENT_SHADER, fragmentShaderSrc);
  if (!fragmentShader)
    return;
  compileAndLinkShaders(gl, program, vertexShader, fragmentShader);
  gl.useProgram(program);
  const vloc = gl.getAttribLocation(program, "a_position");
  const tloc = gl.getAttribLocation(program, "a_texcoord");
  return { program, vloc, tloc };
}
class GameViewRenderer {
  /**
   *
   * @param {HTMLCanvasElement} canvas
   * @param {WebGLContextAttributes} options
   */
  constructor(options = {}) {
    /**
     * @type {WebGLRenderingContext}
     */
    __publicField(this, "gl");
    /**
     * @type {number}
     */
    __publicField(this, "animationFrame");
    __publicField(this, "gameCanvas");
    __publicField(this, "textCanvas");
    __publicField(this, "finalCanvas");
    __publicField(this, "handle2d");
    __publicField(this, "render", () => {
      this.gl.drawArrays(this.gl.TRIANGLE_STRIP, 0, 4);
      this.gl.finish();
      const ctx = this.finalCanvas.getContext("2d");
      if (ctx) {
        ctx.clearRect(0, 0, this.finalCanvas.width, this.finalCanvas.height);
        ctx.drawImage(this.gameCanvas, 0, 0, this.finalCanvas.width, this.finalCanvas.height);
        ctx.drawImage(this.textCanvas, 0, 0, this.finalCanvas.width, this.finalCanvas.height);
      }
      this.animationFrame = requestAnimationFrame(this.render);
    });
    const width = window.innerWidth;
    const height = window.innerHeight;
    const pixel_w = 1 / 1080 * width;
    const pixel_h = 1 / 720 * height;
    const gameCanvas = this.gameCanvas = document.createElement("canvas");
    document.body.appendChild(gameCanvas);
    gameCanvas.id = "gameCanvas";
    gameCanvas.width = window.innerWidth;
    gameCanvas.height = window.innerHeight;
    const textCanvas = this.textCanvas = document.createElement("canvas");
    document.body.appendChild(textCanvas);
    textCanvas.id = "textCanvas";
    textCanvas.width = window.innerWidth;
    textCanvas.height = window.innerHeight;
    const finalCanvas = this.finalCanvas = document.createElement("canvas");
    document.body.appendChild(finalCanvas);
    finalCanvas.id = "finalCanvas";
    finalCanvas.width = window.innerWidth;
    finalCanvas.height = window.innerHeight;
    window.addEventListener("resize", () => {
      this.resize(window.innerWidth, window.innerHeight);
    });
    const gl = gameCanvas.getContext("webgl", {
      antialias: false,
      depth: false,
      alpha: false,
      stencil: false,
      desynchronized: true,
      powerPreference: "high-performance",
      ...options
    });
    if (!gl) {
      throw new Error("Failed to acquire webgl context for GameViewRenderer");
    }
    this.gl = gl;
    const tex = createTexture(gl);
    const { program, vloc, tloc } = createProgram(gl);
    const { vertexBuff, texBuff } = createBuffers(gl);
    gl.useProgram(program);
    gl.bindTexture(gl.TEXTURE_2D, tex);
    gl.uniform1i(gl.getUniformLocation(program, "external_texture"), 0);
    gl.bindBuffer(gl.ARRAY_BUFFER, vertexBuff);
    gl.vertexAttribPointer(vloc, 2, gl.FLOAT, false, 0, 0);
    gl.enableVertexAttribArray(vloc);
    gl.bindBuffer(gl.ARRAY_BUFFER, texBuff);
    gl.vertexAttribPointer(tloc, 2, gl.FLOAT, false, 0, 0);
    gl.enableVertexAttribArray(tloc);
    this.render();
    const img = window.img = new Image();
    img.src = "logo.svg";
    img.onerror = (err) => {
      console.log(err);
    };
    img.onload = () => {
      const draw2d = () => {
        const ctx = textCanvas.getContext("2d");
        if (!ctx)
          return;
        const drawText = (text, font, color, x, y) => {
          ctx.font = font;
          ctx.fillStyle = color;
          ctx.fillText(text, x, y);
        };
        ctx.clearRect(0, 0, textCanvas.width, textCanvas.height);
        const logoSize = 16;
        ctx.textAlign = "start";
        ctx.drawImage(img, 4 * pixel_w, 0 * pixel_h + logoSize * pixel_h - 6 * pixel_h, logoSize * pixel_h, logoSize * pixel_h);
        drawText("RSM.GG Freeroam", `normal normal bold ${12 * pixel_w}px Titillium Web, sans-serif`, "white", 6 * pixel_w + logoSize * pixel_w, 6 * pixel_h + logoSize * pixel_h - 4 * pixel_h);
        drawText(`${(/* @__PURE__ */ new Date()).toISOString()}`, `normal normal normal ${6 * pixel_w}px Titillium Web, sans-serif`, "white", 6 * pixel_w + logoSize * pixel_w, 6 * pixel_h + logoSize * pixel_h + 5 * pixel_h);
        const data = window.data;
        ctx.textAlign = "end";
        drawText(`${data.serverId}/${data.playerServerId}/${data.playerId}`, `normal normal normal ${8 * pixel_w}px Titillium Web, sans-serif`, "white", textCanvas.width, 8 * pixel_h);
      };
      draw2d();
      this.handle2d = setInterval(draw2d, 100);
    };
  }
  /**
   *
   * @param {number} width
   * @param {number} height
   */
  resize(width, height) {
    window.resizeGame(width, height);
    this.gl.viewport(0, 0, width, height);
    this.gl.canvas.width = width;
    this.gl.canvas.height = height;
    console.log("Resized", width, height);
  }
  destroy() {
    if (this.animationFrame) {
      cancelAnimationFrame(this.animationFrame);
    }
    clearInterval(this.handle2d);
    this.gameCanvas.remove();
    this.textCanvas.remove();
    this.finalCanvas.remove();
  }
}
var commonjsGlobal = typeof globalThis !== "undefined" ? globalThis : typeof window !== "undefined" ? window : typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : {};
function getDefaultExportFromCjs(x) {
  return x && x.__esModule && Object.prototype.hasOwnProperty.call(x, "default") ? x["default"] : x;
}
var RecordRTC$1 = { exports: {} };
(function(module) {
  /**
   * {@link https://github.com/muaz-khan/RecordRTC|RecordRTC} is a WebRTC JavaScript library for audio/video as well as screen activity recording. It supports Chrome, Firefox, Opera, Android, and Microsoft Edge. Platforms: Linux, Mac and Windows. 
   * @summary Record audio, video or screen inside the browser.
   * @license {@link https://github.com/muaz-khan/RecordRTC/blob/master/LICENSE|MIT}
   * @author {@link https://MuazKhan.com|Muaz Khan}
   * @typedef RecordRTC
   * @class
   * @example
   * var recorder = RecordRTC(mediaStream or [arrayOfMediaStream], {
   *     type: 'video', // audio or video or gif or canvas
   *     recorderType: MediaStreamRecorder || CanvasRecorder || StereoAudioRecorder || Etc
   * });
   * recorder.startRecording();
   * @see For further information:
   * @see {@link https://github.com/muaz-khan/RecordRTC|RecordRTC Source Code}
   * @param {MediaStream} mediaStream - Single media-stream object, array of media-streams, html-canvas-element, etc.
   * @param {object} config - {type:"video", recorderType: MediaStreamRecorder, disableLogs: true, numberOfAudioChannels: 1, bufferSize: 0, sampleRate: 0, desiredSampRate: 16000, video: HTMLVideoElement, etc.}
   */
  function RecordRTC2(mediaStream, config) {
    if (!mediaStream) {
      throw "First parameter is required.";
    }
    config = config || {
      type: "video"
    };
    config = new RecordRTCConfiguration(mediaStream, config);
    var self2 = this;
    function startRecording(config2) {
      if (!config.disableLogs) {
        console.log("RecordRTC version: ", self2.version);
      }
      if (!!config2) {
        config = new RecordRTCConfiguration(mediaStream, config2);
      }
      if (!config.disableLogs) {
        console.log("started recording " + config.type + " stream.");
      }
      if (mediaRecorder) {
        mediaRecorder.clearRecordedData();
        mediaRecorder.record();
        setState("recording");
        if (self2.recordingDuration) {
          handleRecordingDuration();
        }
        return self2;
      }
      initRecorder(function() {
        if (self2.recordingDuration) {
          handleRecordingDuration();
        }
      });
      return self2;
    }
    function initRecorder(initCallback) {
      if (initCallback) {
        config.initCallback = function() {
          initCallback();
          initCallback = config.initCallback = null;
        };
      }
      var Recorder = new GetRecorderType(mediaStream, config);
      mediaRecorder = new Recorder(mediaStream, config);
      mediaRecorder.record();
      setState("recording");
      if (!config.disableLogs) {
        console.log("Initialized recorderType:", mediaRecorder.constructor.name, "for output-type:", config.type);
      }
    }
    function stopRecording(callback) {
      callback = callback || function() {
      };
      if (!mediaRecorder) {
        warningLog();
        return;
      }
      if (self2.state === "paused") {
        self2.resumeRecording();
        setTimeout(function() {
          stopRecording(callback);
        }, 1);
        return;
      }
      if (self2.state !== "recording" && !config.disableLogs) {
        console.warn('Recording state should be: "recording", however current state is: ', self2.state);
      }
      if (!config.disableLogs) {
        console.log("Stopped recording " + config.type + " stream.");
      }
      if (config.type !== "gif") {
        mediaRecorder.stop(_callback);
      } else {
        mediaRecorder.stop();
        _callback();
      }
      setState("stopped");
      function _callback(__blob) {
        if (!mediaRecorder) {
          if (typeof callback.call === "function") {
            callback.call(self2, "");
          } else {
            callback("");
          }
          return;
        }
        Object.keys(mediaRecorder).forEach(function(key) {
          if (typeof mediaRecorder[key] === "function") {
            return;
          }
          self2[key] = mediaRecorder[key];
        });
        var blob = mediaRecorder.blob;
        if (!blob) {
          if (__blob) {
            mediaRecorder.blob = blob = __blob;
          } else {
            throw "Recording failed.";
          }
        }
        if (blob && !config.disableLogs) {
          console.log(blob.type, "->", bytesToSize(blob.size));
        }
        if (callback) {
          var url;
          try {
            url = URL.createObjectURL(blob);
          } catch (e) {
          }
          if (typeof callback.call === "function") {
            callback.call(self2, url);
          } else {
            callback(url);
          }
        }
        if (!config.autoWriteToDisk) {
          return;
        }
        getDataURL(function(dataURL) {
          var parameter = {};
          parameter[config.type + "Blob"] = dataURL;
          DiskStorage.Store(parameter);
        });
      }
    }
    function pauseRecording() {
      if (!mediaRecorder) {
        warningLog();
        return;
      }
      if (self2.state !== "recording") {
        if (!config.disableLogs) {
          console.warn("Unable to pause the recording. Recording state: ", self2.state);
        }
        return;
      }
      setState("paused");
      mediaRecorder.pause();
      if (!config.disableLogs) {
        console.log("Paused recording.");
      }
    }
    function resumeRecording() {
      if (!mediaRecorder) {
        warningLog();
        return;
      }
      if (self2.state !== "paused") {
        if (!config.disableLogs) {
          console.warn("Unable to resume the recording. Recording state: ", self2.state);
        }
        return;
      }
      setState("recording");
      mediaRecorder.resume();
      if (!config.disableLogs) {
        console.log("Resumed recording.");
      }
    }
    function readFile(_blob) {
      postMessage(new FileReaderSync().readAsDataURL(_blob));
    }
    function getDataURL(callback, _mediaRecorder) {
      if (!callback) {
        throw "Pass a callback function over getDataURL.";
      }
      var blob = _mediaRecorder ? _mediaRecorder.blob : (mediaRecorder || {}).blob;
      if (!blob) {
        if (!config.disableLogs) {
          console.warn("Blob encoder did not finish its job yet.");
        }
        setTimeout(function() {
          getDataURL(callback, _mediaRecorder);
        }, 1e3);
        return;
      }
      if (typeof Worker !== "undefined" && !navigator.mozGetUserMedia) {
        var webWorker = processInWebWorker(readFile);
        webWorker.onmessage = function(event) {
          callback(event.data);
        };
        webWorker.postMessage(blob);
      } else {
        var reader = new FileReader();
        reader.readAsDataURL(blob);
        reader.onload = function(event) {
          callback(event.target.result);
        };
      }
      function processInWebWorker(_function) {
        try {
          var blob2 = URL.createObjectURL(new Blob([
            _function.toString(),
            "this.onmessage =  function (eee) {" + _function.name + "(eee.data);}"
          ], {
            type: "application/javascript"
          }));
          var worker = new Worker(blob2);
          URL.revokeObjectURL(blob2);
          return worker;
        } catch (e) {
        }
      }
    }
    function handleRecordingDuration(counter) {
      counter = counter || 0;
      if (self2.state === "paused") {
        setTimeout(function() {
          handleRecordingDuration(counter);
        }, 1e3);
        return;
      }
      if (self2.state === "stopped") {
        return;
      }
      if (counter >= self2.recordingDuration) {
        stopRecording(self2.onRecordingStopped);
        return;
      }
      counter += 1e3;
      setTimeout(function() {
        handleRecordingDuration(counter);
      }, 1e3);
    }
    function setState(state) {
      if (!self2) {
        return;
      }
      self2.state = state;
      if (typeof self2.onStateChanged.call === "function") {
        self2.onStateChanged.call(self2, state);
      } else {
        self2.onStateChanged(state);
      }
    }
    var WARNING = 'It seems that recorder is destroyed or "startRecording" is not invoked for ' + config.type + " recorder.";
    function warningLog() {
      if (config.disableLogs === true) {
        return;
      }
      console.warn(WARNING);
    }
    var mediaRecorder;
    var returnObject = {
      /**
       * This method starts the recording.
       * @method
       * @memberof RecordRTC
       * @instance
       * @example
       * var recorder = RecordRTC(mediaStream, {
       *     type: 'video'
       * });
       * recorder.startRecording();
       */
      startRecording,
      /**
       * This method stops the recording. It is strongly recommended to get "blob" or "URI" inside the callback to make sure all recorders finished their job.
       * @param {function} callback - Callback to get the recorded blob.
       * @method
       * @memberof RecordRTC
       * @instance
       * @example
       * recorder.stopRecording(function() {
       *     // use either "this" or "recorder" object; both are identical
       *     video.src = this.toURL();
       *     var blob = this.getBlob();
       * });
       */
      stopRecording,
      /**
       * This method pauses the recording. You can resume recording using "resumeRecording" method.
       * @method
       * @memberof RecordRTC
       * @instance
       * @todo Firefox is unable to pause the recording. Fix it.
       * @example
       * recorder.pauseRecording();  // pause the recording
       * recorder.resumeRecording(); // resume again
       */
      pauseRecording,
      /**
       * This method resumes the recording.
       * @method
       * @memberof RecordRTC
       * @instance
       * @example
       * recorder.pauseRecording();  // first of all, pause the recording
       * recorder.resumeRecording(); // now resume it
       */
      resumeRecording,
      /**
       * This method initializes the recording.
       * @method
       * @memberof RecordRTC
       * @instance
       * @todo This method should be deprecated.
       * @example
       * recorder.initRecorder();
       */
      initRecorder,
      /**
       * Ask RecordRTC to auto-stop the recording after 5 minutes.
       * @method
       * @memberof RecordRTC
       * @instance
       * @example
       * var fiveMinutes = 5 * 1000 * 60;
       * recorder.setRecordingDuration(fiveMinutes, function() {
       *    var blob = this.getBlob();
       *    video.src = this.toURL();
       * });
       * 
       * // or otherwise
       * recorder.setRecordingDuration(fiveMinutes).onRecordingStopped(function() {
       *    var blob = this.getBlob();
       *    video.src = this.toURL();
       * });
       */
      setRecordingDuration: function(recordingDuration, callback) {
        if (typeof recordingDuration === "undefined") {
          throw "recordingDuration is required.";
        }
        if (typeof recordingDuration !== "number") {
          throw "recordingDuration must be a number.";
        }
        self2.recordingDuration = recordingDuration;
        self2.onRecordingStopped = callback || function() {
        };
        return {
          onRecordingStopped: function(callback2) {
            self2.onRecordingStopped = callback2;
          }
        };
      },
      /**
       * This method can be used to clear/reset all the recorded data.
       * @method
       * @memberof RecordRTC
       * @instance
       * @todo Figure out the difference between "reset" and "clearRecordedData" methods.
       * @example
       * recorder.clearRecordedData();
       */
      clearRecordedData: function() {
        if (!mediaRecorder) {
          warningLog();
          return;
        }
        mediaRecorder.clearRecordedData();
        if (!config.disableLogs) {
          console.log("Cleared old recorded data.");
        }
      },
      /**
       * Get the recorded blob. Use this method inside the "stopRecording" callback.
       * @method
       * @memberof RecordRTC
       * @instance
       * @example
       * recorder.stopRecording(function() {
       *     var blob = this.getBlob();
       *
       *     var file = new File([blob], 'filename.webm', {
       *         type: 'video/webm'
       *     });
       *
       *     var formData = new FormData();
       *     formData.append('file', file); // upload "File" object rather than a "Blob"
       *     uploadToServer(formData);
       * });
       * @returns {Blob} Returns recorded data as "Blob" object.
       */
      getBlob: function() {
        if (!mediaRecorder) {
          warningLog();
          return;
        }
        return mediaRecorder.blob;
      },
      /**
       * Get data-URI instead of Blob.
       * @param {function} callback - Callback to get the Data-URI.
       * @method
       * @memberof RecordRTC
       * @instance
       * @example
       * recorder.stopRecording(function() {
       *     recorder.getDataURL(function(dataURI) {
       *         video.src = dataURI;
       *     });
       * });
       */
      getDataURL,
      /**
       * Get virtual/temporary URL. Usage of this URL is limited to current tab.
       * @method
       * @memberof RecordRTC
       * @instance
       * @example
       * recorder.stopRecording(function() {
       *     video.src = this.toURL();
       * });
       * @returns {String} Returns a virtual/temporary URL for the recorded "Blob".
       */
      toURL: function() {
        if (!mediaRecorder) {
          warningLog();
          return;
        }
        return URL.createObjectURL(mediaRecorder.blob);
      },
      /**
       * Get internal recording object (i.e. internal module) e.g. MutliStreamRecorder, MediaStreamRecorder, StereoAudioRecorder or WhammyRecorder etc.
       * @method
       * @memberof RecordRTC
       * @instance
       * @example
       * var internalRecorder = recorder.getInternalRecorder();
       * if(internalRecorder instanceof MultiStreamRecorder) {
       *     internalRecorder.addStreams([newAudioStream]);
       *     internalRecorder.resetVideoStreams([screenStream]);
       * }
       * @returns {Object} Returns internal recording object.
       */
      getInternalRecorder: function() {
        return mediaRecorder;
      },
      /**
       * Invoke save-as dialog to save the recorded blob into your disk.
       * @param {string} fileName - Set your own file name.
       * @method
       * @memberof RecordRTC
       * @instance
       * @example
       * recorder.stopRecording(function() {
       *     this.save('file-name');
       *
       *     // or manually:
       *     invokeSaveAsDialog(this.getBlob(), 'filename.webm');
       * });
       */
      save: function(fileName) {
        if (!mediaRecorder) {
          warningLog();
          return;
        }
        invokeSaveAsDialog(mediaRecorder.blob, fileName);
      },
      /**
       * This method gets a blob from indexed-DB storage.
       * @param {function} callback - Callback to get the recorded blob.
       * @method
       * @memberof RecordRTC
       * @instance
       * @example
       * recorder.getFromDisk(function(dataURL) {
       *     video.src = dataURL;
       * });
       */
      getFromDisk: function(callback) {
        if (!mediaRecorder) {
          warningLog();
          return;
        }
        RecordRTC2.getFromDisk(config.type, callback);
      },
      /**
       * This method appends an array of webp images to the recorded video-blob. It takes an "array" object.
       * @type {Array.<Array>}
       * @param {Array} arrayOfWebPImages - Array of webp images.
       * @method
       * @memberof RecordRTC
       * @instance
       * @todo This method should be deprecated.
       * @example
       * var arrayOfWebPImages = [];
       * arrayOfWebPImages.push({
       *     duration: index,
       *     image: 'data:image/webp;base64,...'
       * });
       * recorder.setAdvertisementArray(arrayOfWebPImages);
       */
      setAdvertisementArray: function(arrayOfWebPImages) {
        config.advertisement = [];
        var length = arrayOfWebPImages.length;
        for (var i = 0; i < length; i++) {
          config.advertisement.push({
            duration: i,
            image: arrayOfWebPImages[i]
          });
        }
      },
      /**
       * It is equivalent to <code class="str">"recorder.getBlob()"</code> method. Usage of "getBlob" is recommended, though.
       * @property {Blob} blob - Recorded Blob can be accessed using this property.
       * @memberof RecordRTC
       * @instance
       * @readonly
       * @example
       * recorder.stopRecording(function() {
       *     var blob = this.blob;
       *
       *     // below one is recommended
       *     var blob = this.getBlob();
       * });
       */
      blob: null,
      /**
       * This works only with {recorderType:StereoAudioRecorder}. Use this property on "stopRecording" to verify the encoder's sample-rates.
       * @property {number} bufferSize - Buffer-size used to encode the WAV container
       * @memberof RecordRTC
       * @instance
       * @readonly
       * @example
       * recorder.stopRecording(function() {
       *     alert('Recorder used this buffer-size: ' + this.bufferSize);
       * });
       */
      bufferSize: 0,
      /**
       * This works only with {recorderType:StereoAudioRecorder}. Use this property on "stopRecording" to verify the encoder's sample-rates.
       * @property {number} sampleRate - Sample-rates used to encode the WAV container
       * @memberof RecordRTC
       * @instance
       * @readonly
       * @example
       * recorder.stopRecording(function() {
       *     alert('Recorder used these sample-rates: ' + this.sampleRate);
       * });
       */
      sampleRate: 0,
      /**
       * {recorderType:StereoAudioRecorder} returns ArrayBuffer object.
       * @property {ArrayBuffer} buffer - Audio ArrayBuffer, supported only in Chrome.
       * @memberof RecordRTC
       * @instance
       * @readonly
       * @example
       * recorder.stopRecording(function() {
       *     var arrayBuffer = this.buffer;
       *     alert(arrayBuffer.byteLength);
       * });
       */
      buffer: null,
      /**
       * This method resets the recorder. So that you can reuse single recorder instance many times.
       * @method
       * @memberof RecordRTC
       * @instance
       * @example
       * recorder.reset();
       * recorder.startRecording();
       */
      reset: function() {
        if (self2.state === "recording" && !config.disableLogs) {
          console.warn("Stop an active recorder.");
        }
        if (mediaRecorder && typeof mediaRecorder.clearRecordedData === "function") {
          mediaRecorder.clearRecordedData();
        }
        mediaRecorder = null;
        setState("inactive");
        self2.blob = null;
      },
      /**
       * This method is called whenever recorder's state changes. Use this as an "event".
       * @property {String} state - A recorder's state can be: recording, paused, stopped or inactive.
       * @method
       * @memberof RecordRTC
       * @instance
       * @example
       * recorder.onStateChanged = function(state) {
       *     console.log('Recorder state: ', state);
       * };
       */
      onStateChanged: function(state) {
        if (!config.disableLogs) {
          console.log("Recorder state changed:", state);
        }
      },
      /**
       * A recorder can have inactive, recording, paused or stopped states.
       * @property {String} state - A recorder's state can be: recording, paused, stopped or inactive.
       * @memberof RecordRTC
       * @static
       * @readonly
       * @example
       * // this looper function will keep you updated about the recorder's states.
       * (function looper() {
       *     document.querySelector('h1').innerHTML = 'Recorder\'s state is: ' + recorder.state;
       *     if(recorder.state === 'stopped') return; // ignore+stop
       *     setTimeout(looper, 1000); // update after every 3-seconds
       * })();
       * recorder.startRecording();
       */
      state: "inactive",
      /**
       * Get recorder's readonly state.
       * @method
       * @memberof RecordRTC
       * @example
       * var state = recorder.getState();
       * @returns {String} Returns recording state.
       */
      getState: function() {
        return self2.state;
      },
      /**
       * Destroy RecordRTC instance. Clear all recorders and objects.
       * @method
       * @memberof RecordRTC
       * @example
       * recorder.destroy();
       */
      destroy: function() {
        var disableLogsCache = config.disableLogs;
        config = {
          disableLogs: true
        };
        self2.reset();
        setState("destroyed");
        returnObject = self2 = null;
        if (Storage.AudioContextConstructor) {
          Storage.AudioContextConstructor.close();
          Storage.AudioContextConstructor = null;
        }
        config.disableLogs = disableLogsCache;
        if (!config.disableLogs) {
          console.log("RecordRTC is destroyed.");
        }
      },
      /**
       * RecordRTC version number
       * @property {String} version - Release version number.
       * @memberof RecordRTC
       * @static
       * @readonly
       * @example
       * alert(recorder.version);
       */
      version: "5.6.2"
    };
    if (!this) {
      self2 = returnObject;
      return returnObject;
    }
    for (var prop in returnObject) {
      this[prop] = returnObject[prop];
    }
    self2 = this;
    return returnObject;
  }
  RecordRTC2.version = "5.6.2";
  {
    module.exports = RecordRTC2;
  }
  RecordRTC2.getFromDisk = function(type, callback) {
    if (!callback) {
      throw "callback is mandatory.";
    }
    console.log("Getting recorded " + (type === "all" ? "blobs" : type + " blob ") + " from disk!");
    DiskStorage.Fetch(function(dataURL, _type) {
      if (type !== "all" && _type === type + "Blob" && callback) {
        callback(dataURL);
      }
      if (type === "all" && callback) {
        callback(dataURL, _type.replace("Blob", ""));
      }
    });
  };
  RecordRTC2.writeToDisk = function(options) {
    console.log("Writing recorded blob(s) to disk!");
    options = options || {};
    if (options.audio && options.video && options.gif) {
      options.audio.getDataURL(function(audioDataURL) {
        options.video.getDataURL(function(videoDataURL) {
          options.gif.getDataURL(function(gifDataURL) {
            DiskStorage.Store({
              audioBlob: audioDataURL,
              videoBlob: videoDataURL,
              gifBlob: gifDataURL
            });
          });
        });
      });
    } else if (options.audio && options.video) {
      options.audio.getDataURL(function(audioDataURL) {
        options.video.getDataURL(function(videoDataURL) {
          DiskStorage.Store({
            audioBlob: audioDataURL,
            videoBlob: videoDataURL
          });
        });
      });
    } else if (options.audio && options.gif) {
      options.audio.getDataURL(function(audioDataURL) {
        options.gif.getDataURL(function(gifDataURL) {
          DiskStorage.Store({
            audioBlob: audioDataURL,
            gifBlob: gifDataURL
          });
        });
      });
    } else if (options.video && options.gif) {
      options.video.getDataURL(function(videoDataURL) {
        options.gif.getDataURL(function(gifDataURL) {
          DiskStorage.Store({
            videoBlob: videoDataURL,
            gifBlob: gifDataURL
          });
        });
      });
    } else if (options.audio) {
      options.audio.getDataURL(function(audioDataURL) {
        DiskStorage.Store({
          audioBlob: audioDataURL
        });
      });
    } else if (options.video) {
      options.video.getDataURL(function(videoDataURL) {
        DiskStorage.Store({
          videoBlob: videoDataURL
        });
      });
    } else if (options.gif) {
      options.gif.getDataURL(function(gifDataURL) {
        DiskStorage.Store({
          gifBlob: gifDataURL
        });
      });
    }
  };
  /**
   * {@link RecordRTCConfiguration} is an inner/private helper for {@link RecordRTC}.
   * @summary It configures the 2nd parameter passed over {@link RecordRTC} and returns a valid "config" object.
   * @license {@link https://github.com/muaz-khan/RecordRTC/blob/master/LICENSE|MIT}
   * @author {@link https://MuazKhan.com|Muaz Khan}
   * @typedef RecordRTCConfiguration
   * @class
   * @example
   * var options = RecordRTCConfiguration(mediaStream, options);
   * @see {@link https://github.com/muaz-khan/RecordRTC|RecordRTC Source Code}
   * @param {MediaStream} mediaStream - MediaStream object fetched using getUserMedia API or generated using captureStreamUntilEnded or WebAudio API.
   * @param {object} config - {type:"video", disableLogs: true, numberOfAudioChannels: 1, bufferSize: 0, sampleRate: 0, video: HTMLVideoElement, getNativeBlob:true, etc.}
   */
  function RecordRTCConfiguration(mediaStream, config) {
    if (!config.recorderType && !config.type) {
      if (!!config.audio && !!config.video) {
        config.type = "video";
      } else if (!!config.audio && !config.video) {
        config.type = "audio";
      }
    }
    if (config.recorderType && !config.type) {
      if (config.recorderType === WhammyRecorder || config.recorderType === CanvasRecorder || typeof WebAssemblyRecorder !== "undefined" && config.recorderType === WebAssemblyRecorder) {
        config.type = "video";
      } else if (config.recorderType === GifRecorder) {
        config.type = "gif";
      } else if (config.recorderType === StereoAudioRecorder) {
        config.type = "audio";
      } else if (config.recorderType === MediaStreamRecorder) {
        if (getTracks(mediaStream, "audio").length && getTracks(mediaStream, "video").length) {
          config.type = "video";
        } else if (!getTracks(mediaStream, "audio").length && getTracks(mediaStream, "video").length) {
          config.type = "video";
        } else if (getTracks(mediaStream, "audio").length && !getTracks(mediaStream, "video").length) {
          config.type = "audio";
        } else
          ;
      }
    }
    if (typeof MediaStreamRecorder !== "undefined" && typeof MediaRecorder !== "undefined" && "requestData" in MediaRecorder.prototype) {
      if (!config.mimeType) {
        config.mimeType = "video/webm";
      }
      if (!config.type) {
        config.type = config.mimeType.split("/")[0];
      }
      if (!config.bitsPerSecond)
        ;
    }
    if (!config.type) {
      if (config.mimeType) {
        config.type = config.mimeType.split("/")[0];
      }
      if (!config.type) {
        config.type = "audio";
      }
    }
    return config;
  }
  /**
   * {@link GetRecorderType} is an inner/private helper for {@link RecordRTC}.
   * @summary It returns best recorder-type available for your browser.
   * @license {@link https://github.com/muaz-khan/RecordRTC/blob/master/LICENSE|MIT}
   * @author {@link https://MuazKhan.com|Muaz Khan}
   * @typedef GetRecorderType
   * @class
   * @example
   * var RecorderType = GetRecorderType(options);
   * var recorder = new RecorderType(options);
   * @see {@link https://github.com/muaz-khan/RecordRTC|RecordRTC Source Code}
   * @param {MediaStream} mediaStream - MediaStream object fetched using getUserMedia API or generated using captureStreamUntilEnded or WebAudio API.
   * @param {object} config - {type:"video", disableLogs: true, numberOfAudioChannels: 1, bufferSize: 0, sampleRate: 0, video: HTMLVideoElement, etc.}
   */
  function GetRecorderType(mediaStream, config) {
    var recorder;
    if (isChrome || isEdge || isOpera) {
      recorder = StereoAudioRecorder;
    }
    if (typeof MediaRecorder !== "undefined" && "requestData" in MediaRecorder.prototype && !isChrome) {
      recorder = MediaStreamRecorder;
    }
    if (config.type === "video" && (isChrome || isOpera)) {
      recorder = WhammyRecorder;
      if (typeof WebAssemblyRecorder !== "undefined" && typeof ReadableStream !== "undefined") {
        recorder = WebAssemblyRecorder;
      }
    }
    if (config.type === "gif") {
      recorder = GifRecorder;
    }
    if (config.type === "canvas") {
      recorder = CanvasRecorder;
    }
    if (isMediaRecorderCompatible() && recorder !== CanvasRecorder && recorder !== GifRecorder && typeof MediaRecorder !== "undefined" && "requestData" in MediaRecorder.prototype) {
      if (getTracks(mediaStream, "video").length || getTracks(mediaStream, "audio").length) {
        if (config.type === "audio") {
          if (typeof MediaRecorder.isTypeSupported === "function" && MediaRecorder.isTypeSupported("audio/webm")) {
            recorder = MediaStreamRecorder;
          }
        } else {
          if (typeof MediaRecorder.isTypeSupported === "function" && MediaRecorder.isTypeSupported("video/webm")) {
            recorder = MediaStreamRecorder;
          }
        }
      }
    }
    if (mediaStream instanceof Array && mediaStream.length) {
      recorder = MultiStreamRecorder;
    }
    if (config.recorderType) {
      recorder = config.recorderType;
    }
    if (!config.disableLogs && !!recorder && !!recorder.name) {
      console.log("Using recorderType:", recorder.name || recorder.constructor.name);
    }
    if (!recorder && isSafari) {
      recorder = MediaStreamRecorder;
    }
    return recorder;
  }
  /**
   * MRecordRTC runs on top of {@link RecordRTC} to bring multiple recordings in a single place, by providing simple API.
   * @summary MRecordRTC stands for "Multiple-RecordRTC".
   * @license {@link https://github.com/muaz-khan/RecordRTC/blob/master/LICENSE|MIT}
   * @author {@link https://MuazKhan.com|Muaz Khan}
   * @typedef MRecordRTC
   * @class
   * @example
   * var recorder = new MRecordRTC();
   * recorder.addStream(MediaStream);
   * recorder.mediaType = {
   *     audio: true, // or StereoAudioRecorder or MediaStreamRecorder
   *     video: true, // or WhammyRecorder or MediaStreamRecorder or WebAssemblyRecorder or CanvasRecorder
   *     gif: true    // or GifRecorder
   * };
   * // mimeType is optional and should be set only in advance cases.
   * recorder.mimeType = {
   *     audio: 'audio/wav',
   *     video: 'video/webm',
   *     gif:   'image/gif'
   * };
   * recorder.startRecording();
   * @see For further information:
   * @see {@link https://github.com/muaz-khan/RecordRTC/tree/master/MRecordRTC|MRecordRTC Source Code}
   * @param {MediaStream} mediaStream - MediaStream object fetched using getUserMedia API or generated using captureStreamUntilEnded or WebAudio API.
   * @requires {@link RecordRTC}
   */
  function MRecordRTC(mediaStream) {
    this.addStream = function(_mediaStream) {
      if (_mediaStream) {
        mediaStream = _mediaStream;
      }
    };
    this.mediaType = {
      audio: true,
      video: true
    };
    this.startRecording = function() {
      var mediaType = this.mediaType;
      var recorderType;
      var mimeType = this.mimeType || {
        audio: null,
        video: null,
        gif: null
      };
      if (typeof mediaType.audio !== "function" && isMediaRecorderCompatible() && !getTracks(mediaStream, "audio").length) {
        mediaType.audio = false;
      }
      if (typeof mediaType.video !== "function" && isMediaRecorderCompatible() && !getTracks(mediaStream, "video").length) {
        mediaType.video = false;
      }
      if (typeof mediaType.gif !== "function" && isMediaRecorderCompatible() && !getTracks(mediaStream, "video").length) {
        mediaType.gif = false;
      }
      if (!mediaType.audio && !mediaType.video && !mediaType.gif) {
        throw "MediaStream must have either audio or video tracks.";
      }
      if (!!mediaType.audio) {
        recorderType = null;
        if (typeof mediaType.audio === "function") {
          recorderType = mediaType.audio;
        }
        this.audioRecorder = new RecordRTC2(mediaStream, {
          type: "audio",
          bufferSize: this.bufferSize,
          sampleRate: this.sampleRate,
          numberOfAudioChannels: this.numberOfAudioChannels || 2,
          disableLogs: this.disableLogs,
          recorderType,
          mimeType: mimeType.audio,
          timeSlice: this.timeSlice,
          onTimeStamp: this.onTimeStamp
        });
        if (!mediaType.video) {
          this.audioRecorder.startRecording();
        }
      }
      if (!!mediaType.video) {
        recorderType = null;
        if (typeof mediaType.video === "function") {
          recorderType = mediaType.video;
        }
        var newStream = mediaStream;
        if (isMediaRecorderCompatible() && !!mediaType.audio && typeof mediaType.audio === "function") {
          var videoTrack = getTracks(mediaStream, "video")[0];
          if (isFirefox) {
            newStream = new MediaStream();
            newStream.addTrack(videoTrack);
            if (recorderType && recorderType === WhammyRecorder) {
              recorderType = MediaStreamRecorder;
            }
          } else {
            newStream = new MediaStream();
            newStream.addTrack(videoTrack);
          }
        }
        this.videoRecorder = new RecordRTC2(newStream, {
          type: "video",
          video: this.video,
          canvas: this.canvas,
          frameInterval: this.frameInterval || 10,
          disableLogs: this.disableLogs,
          recorderType,
          mimeType: mimeType.video,
          timeSlice: this.timeSlice,
          onTimeStamp: this.onTimeStamp,
          workerPath: this.workerPath,
          webAssemblyPath: this.webAssemblyPath,
          frameRate: this.frameRate,
          // used by WebAssemblyRecorder; values: usually 30; accepts any.
          bitrate: this.bitrate
          // used by WebAssemblyRecorder; values: 0 to 1000+
        });
        if (!mediaType.audio) {
          this.videoRecorder.startRecording();
        }
      }
      if (!!mediaType.audio && !!mediaType.video) {
        var self2 = this;
        var isSingleRecorder = isMediaRecorderCompatible() === true;
        if (mediaType.audio instanceof StereoAudioRecorder && !!mediaType.video) {
          isSingleRecorder = false;
        } else if (mediaType.audio !== true && mediaType.video !== true && mediaType.audio !== mediaType.video) {
          isSingleRecorder = false;
        }
        if (isSingleRecorder === true) {
          self2.audioRecorder = null;
          self2.videoRecorder.startRecording();
        } else {
          self2.videoRecorder.initRecorder(function() {
            self2.audioRecorder.initRecorder(function() {
              self2.videoRecorder.startRecording();
              self2.audioRecorder.startRecording();
            });
          });
        }
      }
      if (!!mediaType.gif) {
        recorderType = null;
        if (typeof mediaType.gif === "function") {
          recorderType = mediaType.gif;
        }
        this.gifRecorder = new RecordRTC2(mediaStream, {
          type: "gif",
          frameRate: this.frameRate || 200,
          quality: this.quality || 10,
          disableLogs: this.disableLogs,
          recorderType,
          mimeType: mimeType.gif
        });
        this.gifRecorder.startRecording();
      }
    };
    this.stopRecording = function(callback) {
      callback = callback || function() {
      };
      if (this.audioRecorder) {
        this.audioRecorder.stopRecording(function(blobURL) {
          callback(blobURL, "audio");
        });
      }
      if (this.videoRecorder) {
        this.videoRecorder.stopRecording(function(blobURL) {
          callback(blobURL, "video");
        });
      }
      if (this.gifRecorder) {
        this.gifRecorder.stopRecording(function(blobURL) {
          callback(blobURL, "gif");
        });
      }
    };
    this.pauseRecording = function() {
      if (this.audioRecorder) {
        this.audioRecorder.pauseRecording();
      }
      if (this.videoRecorder) {
        this.videoRecorder.pauseRecording();
      }
      if (this.gifRecorder) {
        this.gifRecorder.pauseRecording();
      }
    };
    this.resumeRecording = function() {
      if (this.audioRecorder) {
        this.audioRecorder.resumeRecording();
      }
      if (this.videoRecorder) {
        this.videoRecorder.resumeRecording();
      }
      if (this.gifRecorder) {
        this.gifRecorder.resumeRecording();
      }
    };
    this.getBlob = function(callback) {
      var output = {};
      if (this.audioRecorder) {
        output.audio = this.audioRecorder.getBlob();
      }
      if (this.videoRecorder) {
        output.video = this.videoRecorder.getBlob();
      }
      if (this.gifRecorder) {
        output.gif = this.gifRecorder.getBlob();
      }
      if (callback) {
        callback(output);
      }
      return output;
    };
    this.destroy = function() {
      if (this.audioRecorder) {
        this.audioRecorder.destroy();
        this.audioRecorder = null;
      }
      if (this.videoRecorder) {
        this.videoRecorder.destroy();
        this.videoRecorder = null;
      }
      if (this.gifRecorder) {
        this.gifRecorder.destroy();
        this.gifRecorder = null;
      }
    };
    this.getDataURL = function(callback) {
      this.getBlob(function(blob) {
        if (blob.audio && blob.video) {
          getDataURL(blob.audio, function(_audioDataURL) {
            getDataURL(blob.video, function(_videoDataURL) {
              callback({
                audio: _audioDataURL,
                video: _videoDataURL
              });
            });
          });
        } else if (blob.audio) {
          getDataURL(blob.audio, function(_audioDataURL) {
            callback({
              audio: _audioDataURL
            });
          });
        } else if (blob.video) {
          getDataURL(blob.video, function(_videoDataURL) {
            callback({
              video: _videoDataURL
            });
          });
        }
      });
      function getDataURL(blob, callback00) {
        if (typeof Worker !== "undefined") {
          var webWorker = processInWebWorker(function readFile(_blob) {
            postMessage(new FileReaderSync().readAsDataURL(_blob));
          });
          webWorker.onmessage = function(event) {
            callback00(event.data);
          };
          webWorker.postMessage(blob);
        } else {
          var reader = new FileReader();
          reader.readAsDataURL(blob);
          reader.onload = function(event) {
            callback00(event.target.result);
          };
        }
      }
      function processInWebWorker(_function) {
        var blob = URL.createObjectURL(new Blob([
          _function.toString(),
          "this.onmessage =  function (eee) {" + _function.name + "(eee.data);}"
        ], {
          type: "application/javascript"
        }));
        var worker = new Worker(blob);
        var url;
        if (typeof URL !== "undefined") {
          url = URL;
        } else if (typeof webkitURL !== "undefined") {
          url = webkitURL;
        } else {
          throw "Neither URL nor webkitURL detected.";
        }
        url.revokeObjectURL(blob);
        return worker;
      }
    };
    this.writeToDisk = function() {
      RecordRTC2.writeToDisk({
        audio: this.audioRecorder,
        video: this.videoRecorder,
        gif: this.gifRecorder
      });
    };
    this.save = function(args) {
      args = args || {
        audio: true,
        video: true,
        gif: true
      };
      if (!!args.audio && this.audioRecorder) {
        this.audioRecorder.save(typeof args.audio === "string" ? args.audio : "");
      }
      if (!!args.video && this.videoRecorder) {
        this.videoRecorder.save(typeof args.video === "string" ? args.video : "");
      }
      if (!!args.gif && this.gifRecorder) {
        this.gifRecorder.save(typeof args.gif === "string" ? args.gif : "");
      }
    };
  }
  MRecordRTC.getFromDisk = RecordRTC2.getFromDisk;
  MRecordRTC.writeToDisk = RecordRTC2.writeToDisk;
  if (typeof RecordRTC2 !== "undefined") {
    RecordRTC2.MRecordRTC = MRecordRTC;
  }
  var browserFakeUserAgent = "Fake/5.0 (FakeOS) AppleWebKit/123 (KHTML, like Gecko) Fake/12.3.4567.89 Fake/123.45";
  (function(that) {
    if (!that) {
      return;
    }
    if (typeof window !== "undefined") {
      return;
    }
    if (typeof commonjsGlobal === "undefined") {
      return;
    }
    commonjsGlobal.navigator = {
      userAgent: browserFakeUserAgent,
      getUserMedia: function() {
      }
    };
    if (!commonjsGlobal.console) {
      commonjsGlobal.console = {};
    }
    if (typeof commonjsGlobal.console.log === "undefined" || typeof commonjsGlobal.console.error === "undefined") {
      commonjsGlobal.console.error = commonjsGlobal.console.log = commonjsGlobal.console.log || function() {
        console.log(arguments);
      };
    }
    if (typeof document === "undefined") {
      that.document = {
        documentElement: {
          appendChild: function() {
            return "";
          }
        }
      };
      document.createElement = document.captureStream = document.mozCaptureStream = function() {
        var obj = {
          getContext: function() {
            return obj;
          },
          play: function() {
          },
          pause: function() {
          },
          drawImage: function() {
          },
          toDataURL: function() {
            return "";
          },
          style: {}
        };
        return obj;
      };
      that.HTMLVideoElement = function() {
      };
    }
    if (typeof location === "undefined") {
      that.location = {
        protocol: "file:",
        href: "",
        hash: ""
      };
    }
    if (typeof screen === "undefined") {
      that.screen = {
        width: 0,
        height: 0
      };
    }
    if (typeof URL === "undefined") {
      that.URL = {
        createObjectURL: function() {
          return "";
        },
        revokeObjectURL: function() {
          return "";
        }
      };
    }
    that.window = commonjsGlobal;
  })(typeof commonjsGlobal !== "undefined" ? commonjsGlobal : null);
  var requestAnimationFrame2 = window.requestAnimationFrame;
  if (typeof requestAnimationFrame2 === "undefined") {
    if (typeof webkitRequestAnimationFrame !== "undefined") {
      requestAnimationFrame2 = webkitRequestAnimationFrame;
    } else if (typeof mozRequestAnimationFrame !== "undefined") {
      requestAnimationFrame2 = mozRequestAnimationFrame;
    } else if (typeof msRequestAnimationFrame !== "undefined") {
      requestAnimationFrame2 = msRequestAnimationFrame;
    } else if (typeof requestAnimationFrame2 === "undefined") {
      var lastTime = 0;
      requestAnimationFrame2 = function(callback, element) {
        var currTime = (/* @__PURE__ */ new Date()).getTime();
        var timeToCall = Math.max(0, 16 - (currTime - lastTime));
        var id = setTimeout(function() {
          callback(currTime + timeToCall);
        }, timeToCall);
        lastTime = currTime + timeToCall;
        return id;
      };
    }
  }
  var cancelAnimationFrame2 = window.cancelAnimationFrame;
  if (typeof cancelAnimationFrame2 === "undefined") {
    if (typeof webkitCancelAnimationFrame !== "undefined") {
      cancelAnimationFrame2 = webkitCancelAnimationFrame;
    } else if (typeof mozCancelAnimationFrame !== "undefined") {
      cancelAnimationFrame2 = mozCancelAnimationFrame;
    } else if (typeof msCancelAnimationFrame !== "undefined") {
      cancelAnimationFrame2 = msCancelAnimationFrame;
    } else if (typeof cancelAnimationFrame2 === "undefined") {
      cancelAnimationFrame2 = function(id) {
        clearTimeout(id);
      };
    }
  }
  var AudioContext = window.AudioContext;
  if (typeof AudioContext === "undefined") {
    if (typeof webkitAudioContext !== "undefined") {
      AudioContext = webkitAudioContext;
    }
    if (typeof mozAudioContext !== "undefined") {
      AudioContext = mozAudioContext;
    }
  }
  var URL = window.URL;
  if (typeof URL === "undefined" && typeof webkitURL !== "undefined") {
    URL = webkitURL;
  }
  if (typeof navigator !== "undefined" && typeof navigator.getUserMedia === "undefined") {
    if (typeof navigator.webkitGetUserMedia !== "undefined") {
      navigator.getUserMedia = navigator.webkitGetUserMedia;
    }
    if (typeof navigator.mozGetUserMedia !== "undefined") {
      navigator.getUserMedia = navigator.mozGetUserMedia;
    }
  }
  var isEdge = navigator.userAgent.indexOf("Edge") !== -1 && (!!navigator.msSaveBlob || !!navigator.msSaveOrOpenBlob);
  var isOpera = !!window.opera || navigator.userAgent.indexOf("OPR/") !== -1;
  var isFirefox = navigator.userAgent.toLowerCase().indexOf("firefox") > -1 && "netscape" in window && / rv:/.test(navigator.userAgent);
  var isChrome = !isOpera && !isEdge && !!navigator.webkitGetUserMedia || isElectron() || navigator.userAgent.toLowerCase().indexOf("chrome/") !== -1;
  var isSafari = /^((?!chrome|android).)*safari/i.test(navigator.userAgent);
  if (isSafari && !isChrome && navigator.userAgent.indexOf("CriOS") !== -1) {
    isSafari = false;
    isChrome = true;
  }
  var MediaStream = window.MediaStream;
  if (typeof MediaStream === "undefined" && typeof webkitMediaStream !== "undefined") {
    MediaStream = webkitMediaStream;
  }
  if (typeof MediaStream !== "undefined") {
    if (typeof MediaStream.prototype.stop === "undefined") {
      MediaStream.prototype.stop = function() {
        this.getTracks().forEach(function(track) {
          track.stop();
        });
      };
    }
  }
  function bytesToSize(bytes) {
    var k = 1e3;
    var sizes = ["Bytes", "KB", "MB", "GB", "TB"];
    if (bytes === 0) {
      return "0 Bytes";
    }
    var i = parseInt(Math.floor(Math.log(bytes) / Math.log(k)), 10);
    return (bytes / Math.pow(k, i)).toPrecision(3) + " " + sizes[i];
  }
  function invokeSaveAsDialog(file, fileName) {
    if (!file) {
      throw "Blob object is required.";
    }
    if (!file.type) {
      try {
        file.type = "video/webm";
      } catch (e) {
      }
    }
    var fileExtension = (file.type || "video/webm").split("/")[1];
    if (fileExtension.indexOf(";") !== -1) {
      fileExtension = fileExtension.split(";")[0];
    }
    if (fileName && fileName.indexOf(".") !== -1) {
      var splitted = fileName.split(".");
      fileName = splitted[0];
      fileExtension = splitted[1];
    }
    var fileFullName = (fileName || Math.round(Math.random() * 9999999999) + 888888888) + "." + fileExtension;
    if (typeof navigator.msSaveOrOpenBlob !== "undefined") {
      return navigator.msSaveOrOpenBlob(file, fileFullName);
    } else if (typeof navigator.msSaveBlob !== "undefined") {
      return navigator.msSaveBlob(file, fileFullName);
    }
    var hyperlink = document.createElement("a");
    hyperlink.href = URL.createObjectURL(file);
    hyperlink.download = fileFullName;
    hyperlink.style = "display:none;opacity:0;color:transparent;";
    (document.body || document.documentElement).appendChild(hyperlink);
    if (typeof hyperlink.click === "function") {
      hyperlink.click();
    } else {
      hyperlink.target = "_blank";
      hyperlink.dispatchEvent(new MouseEvent("click", {
        view: window,
        bubbles: true,
        cancelable: true
      }));
    }
    URL.revokeObjectURL(hyperlink.href);
  }
  function isElectron() {
    if (typeof window !== "undefined" && typeof window.process === "object" && window.process.type === "renderer") {
      return true;
    }
    if (typeof process !== "undefined" && typeof process.versions === "object" && !!process.versions.electron) {
      return true;
    }
    if (typeof navigator === "object" && typeof navigator.userAgent === "string" && navigator.userAgent.indexOf("Electron") >= 0) {
      return true;
    }
    return false;
  }
  function getTracks(stream, kind) {
    if (!stream || !stream.getTracks) {
      return [];
    }
    return stream.getTracks().filter(function(t) {
      return t.kind === (kind || "audio");
    });
  }
  function setSrcObject(stream, element) {
    if ("srcObject" in element) {
      element.srcObject = stream;
    } else if ("mozSrcObject" in element) {
      element.mozSrcObject = stream;
    } else {
      element.srcObject = stream;
    }
  }
  function getSeekableBlob(inputBlob, callback) {
    if (typeof EBML === "undefined") {
      throw new Error("Please link: https://www.webrtc-experiment.com/EBML.js");
    }
    var reader = new EBML.Reader();
    var decoder = new EBML.Decoder();
    var tools = EBML.tools;
    var fileReader = new FileReader();
    fileReader.onload = function(e) {
      var ebmlElms = decoder.decode(this.result);
      ebmlElms.forEach(function(element) {
        reader.read(element);
      });
      reader.stop();
      var refinedMetadataBuf = tools.makeMetadataSeekable(reader.metadatas, reader.duration, reader.cues);
      var body = this.result.slice(reader.metadataSize);
      var newBlob = new Blob([refinedMetadataBuf, body], {
        type: "video/webm"
      });
      callback(newBlob);
    };
    fileReader.readAsArrayBuffer(inputBlob);
  }
  if (typeof RecordRTC2 !== "undefined") {
    RecordRTC2.invokeSaveAsDialog = invokeSaveAsDialog;
    RecordRTC2.getTracks = getTracks;
    RecordRTC2.getSeekableBlob = getSeekableBlob;
    RecordRTC2.bytesToSize = bytesToSize;
    RecordRTC2.isElectron = isElectron;
  }
  /**
   * Storage is a standalone object used by {@link RecordRTC} to store reusable objects e.g. "new AudioContext".
   * @license {@link https://github.com/muaz-khan/RecordRTC/blob/master/LICENSE|MIT}
   * @author {@link https://MuazKhan.com|Muaz Khan}
   * @example
   * Storage.AudioContext === webkitAudioContext
   * @property {webkitAudioContext} AudioContext - Keeps a reference to AudioContext object.
   * @see {@link https://github.com/muaz-khan/RecordRTC|RecordRTC Source Code}
   */
  var Storage = {};
  if (typeof AudioContext !== "undefined") {
    Storage.AudioContext = AudioContext;
  } else if (typeof webkitAudioContext !== "undefined") {
    Storage.AudioContext = webkitAudioContext;
  }
  if (typeof RecordRTC2 !== "undefined") {
    RecordRTC2.Storage = Storage;
  }
  function isMediaRecorderCompatible() {
    if (isFirefox || isSafari || isEdge) {
      return true;
    }
    var nAgt = navigator.userAgent;
    var fullVersion = "" + parseFloat(navigator.appVersion);
    var majorVersion = parseInt(navigator.appVersion, 10);
    var verOffset, ix;
    if (isChrome || isOpera) {
      verOffset = nAgt.indexOf("Chrome");
      fullVersion = nAgt.substring(verOffset + 7);
    }
    if ((ix = fullVersion.indexOf(";")) !== -1) {
      fullVersion = fullVersion.substring(0, ix);
    }
    if ((ix = fullVersion.indexOf(" ")) !== -1) {
      fullVersion = fullVersion.substring(0, ix);
    }
    majorVersion = parseInt("" + fullVersion, 10);
    if (isNaN(majorVersion)) {
      fullVersion = "" + parseFloat(navigator.appVersion);
      majorVersion = parseInt(navigator.appVersion, 10);
    }
    return majorVersion >= 49;
  }
  /**
   * MediaStreamRecorder is an abstraction layer for {@link https://w3c.github.io/mediacapture-record/MediaRecorder.html|MediaRecorder API}. It is used by {@link RecordRTC} to record MediaStream(s) in both Chrome and Firefox.
   * @summary Runs top over {@link https://w3c.github.io/mediacapture-record/MediaRecorder.html|MediaRecorder API}.
   * @license {@link https://github.com/muaz-khan/RecordRTC/blob/master/LICENSE|MIT}
   * @author {@link https://github.com/muaz-khan|Muaz Khan}
   * @typedef MediaStreamRecorder
   * @class
   * @example
   * var config = {
   *     mimeType: 'video/webm', // vp8, vp9, h264, mkv, opus/vorbis
   *     audioBitsPerSecond : 256 * 8 * 1024,
   *     videoBitsPerSecond : 256 * 8 * 1024,
   *     bitsPerSecond: 256 * 8 * 1024,  // if this is provided, skip above two
   *     checkForInactiveTracks: true,
   *     timeSlice: 1000, // concatenate intervals based blobs
   *     ondataavailable: function() {} // get intervals based blobs
   * }
   * var recorder = new MediaStreamRecorder(mediaStream, config);
   * recorder.record();
   * recorder.stop(function(blob) {
   *     video.src = URL.createObjectURL(blob);
   *
   *     // or
   *     var blob = recorder.blob;
   * });
   * @see {@link https://github.com/muaz-khan/RecordRTC|RecordRTC Source Code}
   * @param {MediaStream} mediaStream - MediaStream object fetched using getUserMedia API or generated using captureStreamUntilEnded or WebAudio API.
   * @param {object} config - {disableLogs:true, initCallback: function, mimeType: "video/webm", timeSlice: 1000}
   * @throws Will throw an error if first argument "MediaStream" is missing. Also throws error if "MediaRecorder API" are not supported by the browser.
   */
  function MediaStreamRecorder(mediaStream, config) {
    var self2 = this;
    if (typeof mediaStream === "undefined") {
      throw 'First argument "MediaStream" is required.';
    }
    if (typeof MediaRecorder === "undefined") {
      throw "Your browser does not support the Media Recorder API. Please try other modules e.g. WhammyRecorder or StereoAudioRecorder.";
    }
    config = config || {
      // bitsPerSecond: 256 * 8 * 1024,
      mimeType: "video/webm"
    };
    if (config.type === "audio") {
      if (getTracks(mediaStream, "video").length && getTracks(mediaStream, "audio").length) {
        var stream;
        if (!!navigator.mozGetUserMedia) {
          stream = new MediaStream();
          stream.addTrack(getTracks(mediaStream, "audio")[0]);
        } else {
          stream = new MediaStream(getTracks(mediaStream, "audio"));
        }
        mediaStream = stream;
      }
      if (!config.mimeType || config.mimeType.toString().toLowerCase().indexOf("audio") === -1) {
        config.mimeType = isChrome ? "audio/webm" : "audio/ogg";
      }
      if (config.mimeType && config.mimeType.toString().toLowerCase() !== "audio/ogg" && !!navigator.mozGetUserMedia) {
        config.mimeType = "audio/ogg";
      }
    }
    var arrayOfBlobs = [];
    this.getArrayOfBlobs = function() {
      return arrayOfBlobs;
    };
    this.record = function() {
      self2.blob = null;
      self2.clearRecordedData();
      self2.timestamps = [];
      allStates = [];
      arrayOfBlobs = [];
      var recorderHints = config;
      if (!config.disableLogs) {
        console.log("Passing following config over MediaRecorder API.", recorderHints);
      }
      if (mediaRecorder) {
        mediaRecorder = null;
      }
      if (isChrome && !isMediaRecorderCompatible()) {
        recorderHints = "video/vp8";
      }
      if (typeof MediaRecorder.isTypeSupported === "function" && recorderHints.mimeType) {
        if (!MediaRecorder.isTypeSupported(recorderHints.mimeType)) {
          if (!config.disableLogs) {
            console.warn("MediaRecorder API seems unable to record mimeType:", recorderHints.mimeType);
          }
          recorderHints.mimeType = config.type === "audio" ? "audio/webm" : "video/webm";
        }
      }
      try {
        mediaRecorder = new MediaRecorder(mediaStream, recorderHints);
        config.mimeType = recorderHints.mimeType;
      } catch (e) {
        mediaRecorder = new MediaRecorder(mediaStream);
      }
      if (recorderHints.mimeType && !MediaRecorder.isTypeSupported && "canRecordMimeType" in mediaRecorder && mediaRecorder.canRecordMimeType(recorderHints.mimeType) === false) {
        if (!config.disableLogs) {
          console.warn("MediaRecorder API seems unable to record mimeType:", recorderHints.mimeType);
        }
      }
      mediaRecorder.ondataavailable = function(e) {
        if (e.data) {
          allStates.push("ondataavailable: " + bytesToSize(e.data.size));
        }
        if (typeof config.timeSlice === "number") {
          if (e.data && e.data.size) {
            arrayOfBlobs.push(e.data);
            updateTimeStamp();
            if (typeof config.ondataavailable === "function") {
              var blob = config.getNativeBlob ? e.data : new Blob([e.data], {
                type: getMimeType(recorderHints)
              });
              config.ondataavailable(blob);
            }
          }
          return;
        }
        if (!e.data || !e.data.size || e.data.size < 100 || self2.blob) {
          if (self2.recordingCallback) {
            self2.recordingCallback(new Blob([], {
              type: getMimeType(recorderHints)
            }));
            self2.recordingCallback = null;
          }
          return;
        }
        self2.blob = config.getNativeBlob ? e.data : new Blob([e.data], {
          type: getMimeType(recorderHints)
        });
        if (self2.recordingCallback) {
          self2.recordingCallback(self2.blob);
          self2.recordingCallback = null;
        }
      };
      mediaRecorder.onstart = function() {
        allStates.push("started");
      };
      mediaRecorder.onpause = function() {
        allStates.push("paused");
      };
      mediaRecorder.onresume = function() {
        allStates.push("resumed");
      };
      mediaRecorder.onstop = function() {
        allStates.push("stopped");
      };
      mediaRecorder.onerror = function(error) {
        if (!error) {
          return;
        }
        if (!error.name) {
          error.name = "UnknownError";
        }
        allStates.push("error: " + error);
        if (!config.disableLogs) {
          if (error.name.toString().toLowerCase().indexOf("invalidstate") !== -1) {
            console.error("The MediaRecorder is not in a state in which the proposed operation is allowed to be executed.", error);
          } else if (error.name.toString().toLowerCase().indexOf("notsupported") !== -1) {
            console.error("MIME type (", recorderHints.mimeType, ") is not supported.", error);
          } else if (error.name.toString().toLowerCase().indexOf("security") !== -1) {
            console.error("MediaRecorder security error", error);
          } else if (error.name === "OutOfMemory") {
            console.error("The UA has exhaused the available memory. User agents SHOULD provide as much additional information as possible in the message attribute.", error);
          } else if (error.name === "IllegalStreamModification") {
            console.error("A modification to the stream has occurred that makes it impossible to continue recording. An example would be the addition of a Track while recording is occurring. User agents SHOULD provide as much additional information as possible in the message attribute.", error);
          } else if (error.name === "OtherRecordingError") {
            console.error("Used for an fatal error other than those listed above. User agents SHOULD provide as much additional information as possible in the message attribute.", error);
          } else if (error.name === "GenericError") {
            console.error("The UA cannot provide the codec or recording option that has been requested.", error);
          } else {
            console.error("MediaRecorder Error", error);
          }
        }
        (function(looper) {
          if (!self2.manuallyStopped && mediaRecorder && mediaRecorder.state === "inactive") {
            delete config.timeslice;
            mediaRecorder.start(10 * 60 * 1e3);
            return;
          }
          setTimeout(looper, 1e3);
        })();
        if (mediaRecorder.state !== "inactive" && mediaRecorder.state !== "stopped") {
          mediaRecorder.stop();
        }
      };
      if (typeof config.timeSlice === "number") {
        updateTimeStamp();
        mediaRecorder.start(config.timeSlice);
      } else {
        mediaRecorder.start(36e5);
      }
      if (config.initCallback) {
        config.initCallback();
      }
    };
    this.timestamps = [];
    function updateTimeStamp() {
      self2.timestamps.push((/* @__PURE__ */ new Date()).getTime());
      if (typeof config.onTimeStamp === "function") {
        config.onTimeStamp(self2.timestamps[self2.timestamps.length - 1], self2.timestamps);
      }
    }
    function getMimeType(secondObject) {
      if (mediaRecorder && mediaRecorder.mimeType) {
        return mediaRecorder.mimeType;
      }
      return secondObject.mimeType || "video/webm";
    }
    this.stop = function(callback) {
      callback = callback || function() {
      };
      self2.manuallyStopped = true;
      if (!mediaRecorder) {
        return;
      }
      this.recordingCallback = callback;
      if (mediaRecorder.state === "recording") {
        mediaRecorder.stop();
      }
      if (typeof config.timeSlice === "number") {
        setTimeout(function() {
          self2.blob = new Blob(arrayOfBlobs, {
            type: getMimeType(config)
          });
          self2.recordingCallback(self2.blob);
        }, 100);
      }
    };
    this.pause = function() {
      if (!mediaRecorder) {
        return;
      }
      if (mediaRecorder.state === "recording") {
        mediaRecorder.pause();
      }
    };
    this.resume = function() {
      if (!mediaRecorder) {
        return;
      }
      if (mediaRecorder.state === "paused") {
        mediaRecorder.resume();
      }
    };
    this.clearRecordedData = function() {
      if (mediaRecorder && mediaRecorder.state === "recording") {
        self2.stop(clearRecordedDataCB);
      }
      clearRecordedDataCB();
    };
    function clearRecordedDataCB() {
      arrayOfBlobs = [];
      mediaRecorder = null;
      self2.timestamps = [];
    }
    var mediaRecorder;
    this.getInternalRecorder = function() {
      return mediaRecorder;
    };
    function isMediaStreamActive() {
      if ("active" in mediaStream) {
        if (!mediaStream.active) {
          return false;
        }
      } else if ("ended" in mediaStream) {
        if (mediaStream.ended) {
          return false;
        }
      }
      return true;
    }
    this.blob = null;
    this.getState = function() {
      if (!mediaRecorder) {
        return "inactive";
      }
      return mediaRecorder.state || "inactive";
    };
    var allStates = [];
    this.getAllStates = function() {
      return allStates;
    };
    if (typeof config.checkForInactiveTracks === "undefined") {
      config.checkForInactiveTracks = false;
    }
    var self2 = this;
    (function looper() {
      if (!mediaRecorder || config.checkForInactiveTracks === false) {
        return;
      }
      if (isMediaStreamActive() === false) {
        if (!config.disableLogs) {
          console.log("MediaStream seems stopped.");
        }
        self2.stop();
        return;
      }
      setTimeout(looper, 1e3);
    })();
    this.name = "MediaStreamRecorder";
    this.toString = function() {
      return this.name;
    };
  }
  if (typeof RecordRTC2 !== "undefined") {
    RecordRTC2.MediaStreamRecorder = MediaStreamRecorder;
  }
  /**
   * StereoAudioRecorder is a standalone class used by {@link RecordRTC} to bring "stereo" audio-recording in chrome.
   * @summary JavaScript standalone object for stereo audio recording.
   * @license {@link https://github.com/muaz-khan/RecordRTC/blob/master/LICENSE|MIT}
   * @author {@link https://MuazKhan.com|Muaz Khan}
   * @typedef StereoAudioRecorder
   * @class
   * @example
   * var recorder = new StereoAudioRecorder(MediaStream, {
   *     sampleRate: 44100,
   *     bufferSize: 4096
   * });
   * recorder.record();
   * recorder.stop(function(blob) {
   *     video.src = URL.createObjectURL(blob);
   * });
   * @see {@link https://github.com/muaz-khan/RecordRTC|RecordRTC Source Code}
   * @param {MediaStream} mediaStream - MediaStream object fetched using getUserMedia API or generated using captureStreamUntilEnded or WebAudio API.
   * @param {object} config - {sampleRate: 44100, bufferSize: 4096, numberOfAudioChannels: 1, etc.}
   */
  function StereoAudioRecorder(mediaStream, config) {
    if (!getTracks(mediaStream, "audio").length) {
      throw "Your stream has no audio tracks.";
    }
    config = config || {};
    var self2 = this;
    var leftchannel = [];
    var rightchannel = [];
    var recording2 = false;
    var recordingLength = 0;
    var jsAudioNode;
    var numberOfAudioChannels = 2;
    var desiredSampRate = config.desiredSampRate;
    if (config.leftChannel === true) {
      numberOfAudioChannels = 1;
    }
    if (config.numberOfAudioChannels === 1) {
      numberOfAudioChannels = 1;
    }
    if (!numberOfAudioChannels || numberOfAudioChannels < 1) {
      numberOfAudioChannels = 2;
    }
    if (!config.disableLogs) {
      console.log("StereoAudioRecorder is set to record number of channels: " + numberOfAudioChannels);
    }
    if (typeof config.checkForInactiveTracks === "undefined") {
      config.checkForInactiveTracks = true;
    }
    function isMediaStreamActive() {
      if (config.checkForInactiveTracks === false) {
        return true;
      }
      if ("active" in mediaStream) {
        if (!mediaStream.active) {
          return false;
        }
      } else if ("ended" in mediaStream) {
        if (mediaStream.ended) {
          return false;
        }
      }
      return true;
    }
    this.record = function() {
      if (isMediaStreamActive() === false) {
        throw "Please make sure MediaStream is active.";
      }
      resetVariables();
      isAudioProcessStarted = isPaused = false;
      recording2 = true;
      if (typeof config.timeSlice !== "undefined") {
        looper();
      }
    };
    function mergeLeftRightBuffers(config2, callback) {
      function mergeAudioBuffers(config3, cb) {
        var numberOfAudioChannels2 = config3.numberOfAudioChannels;
        var leftBuffers = config3.leftBuffers.slice(0);
        var rightBuffers = config3.rightBuffers.slice(0);
        var sampleRate2 = config3.sampleRate;
        var internalInterleavedLength = config3.internalInterleavedLength;
        var desiredSampRate2 = config3.desiredSampRate;
        if (numberOfAudioChannels2 === 2) {
          leftBuffers = mergeBuffers(leftBuffers, internalInterleavedLength);
          rightBuffers = mergeBuffers(rightBuffers, internalInterleavedLength);
          if (desiredSampRate2) {
            leftBuffers = interpolateArray(leftBuffers, desiredSampRate2, sampleRate2);
            rightBuffers = interpolateArray(rightBuffers, desiredSampRate2, sampleRate2);
          }
        }
        if (numberOfAudioChannels2 === 1) {
          leftBuffers = mergeBuffers(leftBuffers, internalInterleavedLength);
          if (desiredSampRate2) {
            leftBuffers = interpolateArray(leftBuffers, desiredSampRate2, sampleRate2);
          }
        }
        if (desiredSampRate2) {
          sampleRate2 = desiredSampRate2;
        }
        function interpolateArray(data, newSampleRate, oldSampleRate) {
          var fitCount = Math.round(data.length * (newSampleRate / oldSampleRate));
          var newData = [];
          var springFactor = Number((data.length - 1) / (fitCount - 1));
          newData[0] = data[0];
          for (var i2 = 1; i2 < fitCount - 1; i2++) {
            var tmp = i2 * springFactor;
            var before = Number(Math.floor(tmp)).toFixed();
            var after = Number(Math.ceil(tmp)).toFixed();
            var atPoint = tmp - before;
            newData[i2] = linearInterpolate(data[before], data[after], atPoint);
          }
          newData[fitCount - 1] = data[data.length - 1];
          return newData;
        }
        function linearInterpolate(before, after, atPoint) {
          return before + (after - before) * atPoint;
        }
        function mergeBuffers(channelBuffer, rLength) {
          var result = new Float64Array(rLength);
          var offset = 0;
          var lng2 = channelBuffer.length;
          for (var i2 = 0; i2 < lng2; i2++) {
            var buffer2 = channelBuffer[i2];
            result.set(buffer2, offset);
            offset += buffer2.length;
          }
          return result;
        }
        function interleave(leftChannel, rightChannel) {
          var length = leftChannel.length + rightChannel.length;
          var result = new Float64Array(length);
          var inputIndex = 0;
          for (var index2 = 0; index2 < length; ) {
            result[index2++] = leftChannel[inputIndex];
            result[index2++] = rightChannel[inputIndex];
            inputIndex++;
          }
          return result;
        }
        function writeUTFBytes(view2, offset, string) {
          var lng2 = string.length;
          for (var i2 = 0; i2 < lng2; i2++) {
            view2.setUint8(offset + i2, string.charCodeAt(i2));
          }
        }
        var interleaved;
        if (numberOfAudioChannels2 === 2) {
          interleaved = interleave(leftBuffers, rightBuffers);
        }
        if (numberOfAudioChannels2 === 1) {
          interleaved = leftBuffers;
        }
        var interleavedLength = interleaved.length;
        var resultingBufferLength = 44 + interleavedLength * 2;
        var buffer = new ArrayBuffer(resultingBufferLength);
        var view = new DataView(buffer);
        writeUTFBytes(view, 0, "RIFF");
        view.setUint32(4, 36 + interleavedLength * 2, true);
        writeUTFBytes(view, 8, "WAVE");
        writeUTFBytes(view, 12, "fmt ");
        view.setUint32(16, 16, true);
        view.setUint16(20, 1, true);
        view.setUint16(22, numberOfAudioChannels2, true);
        view.setUint32(24, sampleRate2, true);
        view.setUint32(28, sampleRate2 * numberOfAudioChannels2 * 2, true);
        view.setUint16(32, numberOfAudioChannels2 * 2, true);
        view.setUint16(34, 16, true);
        writeUTFBytes(view, 36, "data");
        view.setUint32(40, interleavedLength * 2, true);
        var lng = interleavedLength;
        var index = 44;
        var volume = 1;
        for (var i = 0; i < lng; i++) {
          view.setInt16(index, interleaved[i] * (32767 * volume), true);
          index += 2;
        }
        if (cb) {
          return cb({
            buffer,
            view
          });
        }
        postMessage({
          buffer,
          view
        });
      }
      if (config2.noWorker) {
        mergeAudioBuffers(config2, function(data) {
          callback(data.buffer, data.view);
        });
        return;
      }
      var webWorker = processInWebWorker(mergeAudioBuffers);
      webWorker.onmessage = function(event) {
        callback(event.data.buffer, event.data.view);
        URL.revokeObjectURL(webWorker.workerURL);
        webWorker.terminate();
      };
      webWorker.postMessage(config2);
    }
    function processInWebWorker(_function) {
      var workerURL = URL.createObjectURL(new Blob([
        _function.toString(),
        ";this.onmessage =  function (eee) {" + _function.name + "(eee.data);}"
      ], {
        type: "application/javascript"
      }));
      var worker = new Worker(workerURL);
      worker.workerURL = workerURL;
      return worker;
    }
    this.stop = function(callback) {
      callback = callback || function() {
      };
      recording2 = false;
      mergeLeftRightBuffers({
        desiredSampRate,
        sampleRate,
        numberOfAudioChannels,
        internalInterleavedLength: recordingLength,
        leftBuffers: leftchannel,
        rightBuffers: numberOfAudioChannels === 1 ? [] : rightchannel,
        noWorker: config.noWorker
      }, function(buffer, view) {
        self2.blob = new Blob([view], {
          type: "audio/wav"
        });
        self2.buffer = new ArrayBuffer(view.buffer.byteLength);
        self2.view = view;
        self2.sampleRate = desiredSampRate || sampleRate;
        self2.bufferSize = bufferSize;
        self2.length = recordingLength;
        isAudioProcessStarted = false;
        if (callback) {
          callback(self2.blob);
        }
      });
    };
    if (typeof RecordRTC2.Storage === "undefined") {
      RecordRTC2.Storage = {
        AudioContextConstructor: null,
        AudioContext: window.AudioContext || window.webkitAudioContext
      };
    }
    if (!RecordRTC2.Storage.AudioContextConstructor || RecordRTC2.Storage.AudioContextConstructor.state === "closed") {
      RecordRTC2.Storage.AudioContextConstructor = new RecordRTC2.Storage.AudioContext();
    }
    var context = RecordRTC2.Storage.AudioContextConstructor;
    var audioInput = context.createMediaStreamSource(mediaStream);
    var legalBufferValues = [0, 256, 512, 1024, 2048, 4096, 8192, 16384];
    var bufferSize = typeof config.bufferSize === "undefined" ? 4096 : config.bufferSize;
    if (legalBufferValues.indexOf(bufferSize) === -1) {
      if (!config.disableLogs) {
        console.log("Legal values for buffer-size are " + JSON.stringify(legalBufferValues, null, "	"));
      }
    }
    if (context.createJavaScriptNode) {
      jsAudioNode = context.createJavaScriptNode(bufferSize, numberOfAudioChannels, numberOfAudioChannels);
    } else if (context.createScriptProcessor) {
      jsAudioNode = context.createScriptProcessor(bufferSize, numberOfAudioChannels, numberOfAudioChannels);
    } else {
      throw "WebAudio API has no support on this browser.";
    }
    audioInput.connect(jsAudioNode);
    if (!config.bufferSize) {
      bufferSize = jsAudioNode.bufferSize;
    }
    var sampleRate = typeof config.sampleRate !== "undefined" ? config.sampleRate : context.sampleRate || 44100;
    if (sampleRate < 22050 || sampleRate > 96e3) {
      if (!config.disableLogs) {
        console.log("sample-rate must be under range 22050 and 96000.");
      }
    }
    if (!config.disableLogs) {
      if (config.desiredSampRate) {
        console.log("Desired sample-rate: " + config.desiredSampRate);
      }
    }
    var isPaused = false;
    this.pause = function() {
      isPaused = true;
    };
    this.resume = function() {
      if (isMediaStreamActive() === false) {
        throw "Please make sure MediaStream is active.";
      }
      if (!recording2) {
        if (!config.disableLogs) {
          console.log("Seems recording has been restarted.");
        }
        this.record();
        return;
      }
      isPaused = false;
    };
    this.clearRecordedData = function() {
      config.checkForInactiveTracks = false;
      if (recording2) {
        this.stop(clearRecordedDataCB);
      }
      clearRecordedDataCB();
    };
    function resetVariables() {
      leftchannel = [];
      rightchannel = [];
      recordingLength = 0;
      isAudioProcessStarted = false;
      recording2 = false;
      isPaused = false;
      context = null;
      self2.leftchannel = leftchannel;
      self2.rightchannel = rightchannel;
      self2.numberOfAudioChannels = numberOfAudioChannels;
      self2.desiredSampRate = desiredSampRate;
      self2.sampleRate = sampleRate;
      self2.recordingLength = recordingLength;
      intervalsBasedBuffers = {
        left: [],
        right: [],
        recordingLength: 0
      };
    }
    function clearRecordedDataCB() {
      if (jsAudioNode) {
        jsAudioNode.onaudioprocess = null;
        jsAudioNode.disconnect();
        jsAudioNode = null;
      }
      if (audioInput) {
        audioInput.disconnect();
        audioInput = null;
      }
      resetVariables();
    }
    this.name = "StereoAudioRecorder";
    this.toString = function() {
      return this.name;
    };
    var isAudioProcessStarted = false;
    function onAudioProcessDataAvailable(e) {
      if (isPaused) {
        return;
      }
      if (isMediaStreamActive() === false) {
        if (!config.disableLogs) {
          console.log("MediaStream seems stopped.");
        }
        jsAudioNode.disconnect();
        recording2 = false;
      }
      if (!recording2) {
        if (audioInput) {
          audioInput.disconnect();
          audioInput = null;
        }
        return;
      }
      if (!isAudioProcessStarted) {
        isAudioProcessStarted = true;
        if (config.onAudioProcessStarted) {
          config.onAudioProcessStarted();
        }
        if (config.initCallback) {
          config.initCallback();
        }
      }
      var left = e.inputBuffer.getChannelData(0);
      var chLeft = new Float32Array(left);
      leftchannel.push(chLeft);
      if (numberOfAudioChannels === 2) {
        var right = e.inputBuffer.getChannelData(1);
        var chRight = new Float32Array(right);
        rightchannel.push(chRight);
      }
      recordingLength += bufferSize;
      self2.recordingLength = recordingLength;
      if (typeof config.timeSlice !== "undefined") {
        intervalsBasedBuffers.recordingLength += bufferSize;
        intervalsBasedBuffers.left.push(chLeft);
        if (numberOfAudioChannels === 2) {
          intervalsBasedBuffers.right.push(chRight);
        }
      }
    }
    jsAudioNode.onaudioprocess = onAudioProcessDataAvailable;
    if (context.createMediaStreamDestination) {
      jsAudioNode.connect(context.createMediaStreamDestination());
    } else {
      jsAudioNode.connect(context.destination);
    }
    this.leftchannel = leftchannel;
    this.rightchannel = rightchannel;
    this.numberOfAudioChannels = numberOfAudioChannels;
    this.desiredSampRate = desiredSampRate;
    this.sampleRate = sampleRate;
    self2.recordingLength = recordingLength;
    var intervalsBasedBuffers = {
      left: [],
      right: [],
      recordingLength: 0
    };
    function looper() {
      if (!recording2 || typeof config.ondataavailable !== "function" || typeof config.timeSlice === "undefined") {
        return;
      }
      if (intervalsBasedBuffers.left.length) {
        mergeLeftRightBuffers({
          desiredSampRate,
          sampleRate,
          numberOfAudioChannels,
          internalInterleavedLength: intervalsBasedBuffers.recordingLength,
          leftBuffers: intervalsBasedBuffers.left,
          rightBuffers: numberOfAudioChannels === 1 ? [] : intervalsBasedBuffers.right
        }, function(buffer, view) {
          var blob = new Blob([view], {
            type: "audio/wav"
          });
          config.ondataavailable(blob);
          setTimeout(looper, config.timeSlice);
        });
        intervalsBasedBuffers = {
          left: [],
          right: [],
          recordingLength: 0
        };
      } else {
        setTimeout(looper, config.timeSlice);
      }
    }
  }
  if (typeof RecordRTC2 !== "undefined") {
    RecordRTC2.StereoAudioRecorder = StereoAudioRecorder;
  }
  /**
   * CanvasRecorder is a standalone class used by {@link RecordRTC} to bring HTML5-Canvas recording into video WebM. It uses HTML2Canvas library and runs top over {@link Whammy}.
   * @summary HTML2Canvas recording into video WebM.
   * @license {@link https://github.com/muaz-khan/RecordRTC/blob/master/LICENSE|MIT}
   * @author {@link https://MuazKhan.com|Muaz Khan}
   * @typedef CanvasRecorder
   * @class
   * @example
   * var recorder = new CanvasRecorder(htmlElement, { disableLogs: true, useWhammyRecorder: true });
   * recorder.record();
   * recorder.stop(function(blob) {
   *     video.src = URL.createObjectURL(blob);
   * });
   * @see {@link https://github.com/muaz-khan/RecordRTC|RecordRTC Source Code}
   * @param {HTMLElement} htmlElement - querySelector/getElementById/getElementsByTagName[0]/etc.
   * @param {object} config - {disableLogs:true, initCallback: function}
   */
  function CanvasRecorder(htmlElement, config) {
    if (typeof html2canvas === "undefined") {
      throw "Please link: https://www.webrtc-experiment.com/screenshot.js";
    }
    config = config || {};
    if (!config.frameInterval) {
      config.frameInterval = 10;
    }
    var isCanvasSupportsStreamCapturing = false;
    ["captureStream", "mozCaptureStream", "webkitCaptureStream"].forEach(function(item) {
      if (item in document.createElement("canvas")) {
        isCanvasSupportsStreamCapturing = true;
      }
    });
    var _isChrome = (!!window.webkitRTCPeerConnection || !!window.webkitGetUserMedia) && !!window.chrome;
    var chromeVersion = 50;
    var matchArray = navigator.userAgent.match(/Chrom(e|ium)\/([0-9]+)\./);
    if (_isChrome && matchArray && matchArray[2]) {
      chromeVersion = parseInt(matchArray[2], 10);
    }
    if (_isChrome && chromeVersion < 52) {
      isCanvasSupportsStreamCapturing = false;
    }
    if (config.useWhammyRecorder) {
      isCanvasSupportsStreamCapturing = false;
    }
    var globalCanvas, mediaStreamRecorder;
    if (isCanvasSupportsStreamCapturing) {
      if (!config.disableLogs) {
        console.log("Your browser supports both MediRecorder API and canvas.captureStream!");
      }
      if (htmlElement instanceof HTMLCanvasElement) {
        globalCanvas = htmlElement;
      } else if (htmlElement instanceof CanvasRenderingContext2D) {
        globalCanvas = htmlElement.canvas;
      } else {
        throw "Please pass either HTMLCanvasElement or CanvasRenderingContext2D.";
      }
    } else if (!!navigator.mozGetUserMedia) {
      if (!config.disableLogs) {
        console.error("Canvas recording is NOT supported in Firefox.");
      }
    }
    var isRecording;
    this.record = function() {
      isRecording = true;
      if (isCanvasSupportsStreamCapturing && !config.useWhammyRecorder) {
        var canvasMediaStream;
        if ("captureStream" in globalCanvas) {
          canvasMediaStream = globalCanvas.captureStream(25);
        } else if ("mozCaptureStream" in globalCanvas) {
          canvasMediaStream = globalCanvas.mozCaptureStream(25);
        } else if ("webkitCaptureStream" in globalCanvas) {
          canvasMediaStream = globalCanvas.webkitCaptureStream(25);
        }
        try {
          var mdStream = new MediaStream();
          mdStream.addTrack(getTracks(canvasMediaStream, "video")[0]);
          canvasMediaStream = mdStream;
        } catch (e) {
        }
        if (!canvasMediaStream) {
          throw "captureStream API are NOT available.";
        }
        mediaStreamRecorder = new MediaStreamRecorder(canvasMediaStream, {
          mimeType: config.mimeType || "video/webm"
        });
        mediaStreamRecorder.record();
      } else {
        whammy.frames = [];
        lastTime2 = (/* @__PURE__ */ new Date()).getTime();
        drawCanvasFrame();
      }
      if (config.initCallback) {
        config.initCallback();
      }
    };
    this.getWebPImages = function(callback) {
      if (htmlElement.nodeName.toLowerCase() !== "canvas") {
        callback();
        return;
      }
      var framesLength = whammy.frames.length;
      whammy.frames.forEach(function(frame, idx) {
        var framesRemaining = framesLength - idx;
        if (!config.disableLogs) {
          console.log(framesRemaining + "/" + framesLength + " frames remaining");
        }
        if (config.onEncodingCallback) {
          config.onEncodingCallback(framesRemaining, framesLength);
        }
        var webp = frame.image.toDataURL("image/webp", 1);
        whammy.frames[idx].image = webp;
      });
      if (!config.disableLogs) {
        console.log("Generating WebM");
      }
      callback();
    };
    this.stop = function(callback) {
      isRecording = false;
      var that = this;
      if (isCanvasSupportsStreamCapturing && mediaStreamRecorder) {
        mediaStreamRecorder.stop(callback);
        return;
      }
      this.getWebPImages(function() {
        whammy.compile(function(blob) {
          if (!config.disableLogs) {
            console.log("Recording finished!");
          }
          that.blob = blob;
          if (that.blob.forEach) {
            that.blob = new Blob([], {
              type: "video/webm"
            });
          }
          if (callback) {
            callback(that.blob);
          }
          whammy.frames = [];
        });
      });
    };
    var isPausedRecording = false;
    this.pause = function() {
      isPausedRecording = true;
      if (mediaStreamRecorder instanceof MediaStreamRecorder) {
        mediaStreamRecorder.pause();
        return;
      }
    };
    this.resume = function() {
      isPausedRecording = false;
      if (mediaStreamRecorder instanceof MediaStreamRecorder) {
        mediaStreamRecorder.resume();
        return;
      }
      if (!isRecording) {
        this.record();
      }
    };
    this.clearRecordedData = function() {
      if (isRecording) {
        this.stop(clearRecordedDataCB);
      }
      clearRecordedDataCB();
    };
    function clearRecordedDataCB() {
      whammy.frames = [];
      isRecording = false;
      isPausedRecording = false;
    }
    this.name = "CanvasRecorder";
    this.toString = function() {
      return this.name;
    };
    function cloneCanvas() {
      var newCanvas = document.createElement("canvas");
      var context = newCanvas.getContext("2d");
      newCanvas.width = htmlElement.width;
      newCanvas.height = htmlElement.height;
      context.drawImage(htmlElement, 0, 0);
      return newCanvas;
    }
    function drawCanvasFrame() {
      if (isPausedRecording) {
        lastTime2 = (/* @__PURE__ */ new Date()).getTime();
        return setTimeout(drawCanvasFrame, 500);
      }
      if (htmlElement.nodeName.toLowerCase() === "canvas") {
        var duration = (/* @__PURE__ */ new Date()).getTime() - lastTime2;
        lastTime2 = (/* @__PURE__ */ new Date()).getTime();
        whammy.frames.push({
          image: cloneCanvas(),
          duration
        });
        if (isRecording) {
          setTimeout(drawCanvasFrame, config.frameInterval);
        }
        return;
      }
      html2canvas(htmlElement, {
        grabMouse: typeof config.showMousePointer === "undefined" || config.showMousePointer,
        onrendered: function(canvas) {
          var duration2 = (/* @__PURE__ */ new Date()).getTime() - lastTime2;
          if (!duration2) {
            return setTimeout(drawCanvasFrame, config.frameInterval);
          }
          lastTime2 = (/* @__PURE__ */ new Date()).getTime();
          whammy.frames.push({
            image: canvas.toDataURL("image/webp", 1),
            duration: duration2
          });
          if (isRecording) {
            setTimeout(drawCanvasFrame, config.frameInterval);
          }
        }
      });
    }
    var lastTime2 = (/* @__PURE__ */ new Date()).getTime();
    var whammy = new Whammy.Video(100);
  }
  if (typeof RecordRTC2 !== "undefined") {
    RecordRTC2.CanvasRecorder = CanvasRecorder;
  }
  /**
   * WhammyRecorder is a standalone class used by {@link RecordRTC} to bring video recording in Chrome. It runs top over {@link Whammy}.
   * @summary Video recording feature in Chrome.
   * @license {@link https://github.com/muaz-khan/RecordRTC/blob/master/LICENSE|MIT}
   * @author {@link https://MuazKhan.com|Muaz Khan}
   * @typedef WhammyRecorder
   * @class
   * @example
   * var recorder = new WhammyRecorder(mediaStream);
   * recorder.record();
   * recorder.stop(function(blob) {
   *     video.src = URL.createObjectURL(blob);
   * });
   * @see {@link https://github.com/muaz-khan/RecordRTC|RecordRTC Source Code}
   * @param {MediaStream} mediaStream - MediaStream object fetched using getUserMedia API or generated using captureStreamUntilEnded or WebAudio API.
   * @param {object} config - {disableLogs: true, initCallback: function, video: HTMLVideoElement, etc.}
   */
  function WhammyRecorder(mediaStream, config) {
    config = config || {};
    if (!config.frameInterval) {
      config.frameInterval = 10;
    }
    if (!config.disableLogs) {
      console.log("Using frames-interval:", config.frameInterval);
    }
    this.record = function() {
      if (!config.width) {
        config.width = 320;
      }
      if (!config.height) {
        config.height = 240;
      }
      if (!config.video) {
        config.video = {
          width: config.width,
          height: config.height
        };
      }
      if (!config.canvas) {
        config.canvas = {
          width: config.width,
          height: config.height
        };
      }
      canvas.width = config.canvas.width || 320;
      canvas.height = config.canvas.height || 240;
      context = canvas.getContext("2d");
      if (config.video && config.video instanceof HTMLVideoElement) {
        video = config.video.cloneNode();
        if (config.initCallback) {
          config.initCallback();
        }
      } else {
        video = document.createElement("video");
        setSrcObject(mediaStream, video);
        video.onloadedmetadata = function() {
          if (config.initCallback) {
            config.initCallback();
          }
        };
        video.width = config.video.width;
        video.height = config.video.height;
      }
      video.muted = true;
      video.play();
      lastTime2 = (/* @__PURE__ */ new Date()).getTime();
      whammy = new Whammy.Video();
      if (!config.disableLogs) {
        console.log("canvas resolutions", canvas.width, "*", canvas.height);
        console.log("video width/height", video.width || canvas.width, "*", video.height || canvas.height);
      }
      drawFrames(config.frameInterval);
    };
    function drawFrames(frameInterval) {
      frameInterval = typeof frameInterval !== "undefined" ? frameInterval : 10;
      var duration = (/* @__PURE__ */ new Date()).getTime() - lastTime2;
      if (!duration) {
        return setTimeout(drawFrames, frameInterval, frameInterval);
      }
      if (isPausedRecording) {
        lastTime2 = (/* @__PURE__ */ new Date()).getTime();
        return setTimeout(drawFrames, 100);
      }
      lastTime2 = (/* @__PURE__ */ new Date()).getTime();
      if (video.paused) {
        video.play();
      }
      context.drawImage(video, 0, 0, canvas.width, canvas.height);
      whammy.frames.push({
        duration,
        image: canvas.toDataURL("image/webp")
      });
      if (!isStopDrawing) {
        setTimeout(drawFrames, frameInterval, frameInterval);
      }
    }
    function asyncLoop(o) {
      var i = -1, length = o.length;
      (function loop() {
        i++;
        if (i === length) {
          o.callback();
          return;
        }
        setTimeout(function() {
          o.functionToLoop(loop, i);
        }, 1);
      })();
    }
    function dropBlackFrames(_frames, _framesToCheck, _pixTolerance, _frameTolerance, callback) {
      var localCanvas = document.createElement("canvas");
      localCanvas.width = canvas.width;
      localCanvas.height = canvas.height;
      var context2d = localCanvas.getContext("2d");
      var resultFrames = [];
      var checkUntilNotBlack = _framesToCheck === -1;
      var endCheckFrame = _framesToCheck && _framesToCheck > 0 && _framesToCheck <= _frames.length ? _framesToCheck : _frames.length;
      var sampleColor = {
        r: 0,
        g: 0,
        b: 0
      };
      var maxColorDifference = Math.sqrt(
        Math.pow(255, 2) + Math.pow(255, 2) + Math.pow(255, 2)
      );
      var pixTolerance = _pixTolerance && _pixTolerance >= 0 && _pixTolerance <= 1 ? _pixTolerance : 0;
      var frameTolerance = _frameTolerance && _frameTolerance >= 0 && _frameTolerance <= 1 ? _frameTolerance : 0;
      var doNotCheckNext = false;
      asyncLoop({
        length: endCheckFrame,
        functionToLoop: function(loop, f) {
          var matchPixCount, endPixCheck, maxPixCount;
          var finishImage = function() {
            if (!doNotCheckNext && maxPixCount - matchPixCount <= maxPixCount * frameTolerance)
              ;
            else {
              if (checkUntilNotBlack) {
                doNotCheckNext = true;
              }
              resultFrames.push(_frames[f]);
            }
            loop();
          };
          if (!doNotCheckNext) {
            var image = new Image();
            image.onload = function() {
              context2d.drawImage(image, 0, 0, canvas.width, canvas.height);
              var imageData = context2d.getImageData(0, 0, canvas.width, canvas.height);
              matchPixCount = 0;
              endPixCheck = imageData.data.length;
              maxPixCount = imageData.data.length / 4;
              for (var pix = 0; pix < endPixCheck; pix += 4) {
                var currentColor = {
                  r: imageData.data[pix],
                  g: imageData.data[pix + 1],
                  b: imageData.data[pix + 2]
                };
                var colorDifference = Math.sqrt(
                  Math.pow(currentColor.r - sampleColor.r, 2) + Math.pow(currentColor.g - sampleColor.g, 2) + Math.pow(currentColor.b - sampleColor.b, 2)
                );
                if (colorDifference <= maxColorDifference * pixTolerance) {
                  matchPixCount++;
                }
              }
              finishImage();
            };
            image.src = _frames[f].image;
          } else {
            finishImage();
          }
        },
        callback: function() {
          resultFrames = resultFrames.concat(_frames.slice(endCheckFrame));
          if (resultFrames.length <= 0) {
            resultFrames.push(_frames[_frames.length - 1]);
          }
          callback(resultFrames);
        }
      });
    }
    var isStopDrawing = false;
    this.stop = function(callback) {
      callback = callback || function() {
      };
      isStopDrawing = true;
      var _this = this;
      setTimeout(function() {
        dropBlackFrames(whammy.frames, -1, null, null, function(frames) {
          whammy.frames = frames;
          if (config.advertisement && config.advertisement.length) {
            whammy.frames = config.advertisement.concat(whammy.frames);
          }
          whammy.compile(function(blob) {
            _this.blob = blob;
            if (_this.blob.forEach) {
              _this.blob = new Blob([], {
                type: "video/webm"
              });
            }
            if (callback) {
              callback(_this.blob);
            }
          });
        });
      }, 10);
    };
    var isPausedRecording = false;
    this.pause = function() {
      isPausedRecording = true;
    };
    this.resume = function() {
      isPausedRecording = false;
      if (isStopDrawing) {
        this.record();
      }
    };
    this.clearRecordedData = function() {
      if (!isStopDrawing) {
        this.stop(clearRecordedDataCB);
      }
      clearRecordedDataCB();
    };
    function clearRecordedDataCB() {
      whammy.frames = [];
      isStopDrawing = true;
      isPausedRecording = false;
    }
    this.name = "WhammyRecorder";
    this.toString = function() {
      return this.name;
    };
    var canvas = document.createElement("canvas");
    var context = canvas.getContext("2d");
    var video;
    var lastTime2;
    var whammy;
  }
  if (typeof RecordRTC2 !== "undefined") {
    RecordRTC2.WhammyRecorder = WhammyRecorder;
  }
  /**
   * Whammy is a standalone class used by {@link RecordRTC} to bring video recording in Chrome. It is written by {@link https://github.com/antimatter15|antimatter15}
   * @summary A real time javascript webm encoder based on a canvas hack.
   * @license {@link https://github.com/muaz-khan/RecordRTC/blob/master/LICENSE|MIT}
   * @author {@link https://MuazKhan.com|Muaz Khan}
   * @typedef Whammy
   * @class
   * @example
   * var recorder = new Whammy().Video(15);
   * recorder.add(context || canvas || dataURL);
   * var output = recorder.compile();
   * @see {@link https://github.com/muaz-khan/RecordRTC|RecordRTC Source Code}
   */
  var Whammy = function() {
    function WhammyVideo(duration) {
      this.frames = [];
      this.duration = duration || 1;
      this.quality = 0.8;
    }
    WhammyVideo.prototype.add = function(frame, duration) {
      if ("canvas" in frame) {
        frame = frame.canvas;
      }
      if ("toDataURL" in frame) {
        frame = frame.toDataURL("image/webp", this.quality);
      }
      if (!/^data:image\/webp;base64,/ig.test(frame)) {
        throw "Input must be formatted properly as a base64 encoded DataURI of type image/webp";
      }
      this.frames.push({
        image: frame,
        duration: duration || this.duration
      });
    };
    function processInWebWorker(_function) {
      var blob = URL.createObjectURL(new Blob([
        _function.toString(),
        "this.onmessage =  function (eee) {" + _function.name + "(eee.data);}"
      ], {
        type: "application/javascript"
      }));
      var worker = new Worker(blob);
      URL.revokeObjectURL(blob);
      return worker;
    }
    function whammyInWebWorker(frames) {
      function ArrayToWebM(frames2) {
        var info = checkFrames(frames2);
        if (!info) {
          return [];
        }
        var clusterMaxDuration = 3e4;
        var EBML2 = [{
          "id": 440786851,
          // EBML
          "data": [{
            "data": 1,
            "id": 17030
            // EBMLVersion
          }, {
            "data": 1,
            "id": 17143
            // EBMLReadVersion
          }, {
            "data": 4,
            "id": 17138
            // EBMLMaxIDLength
          }, {
            "data": 8,
            "id": 17139
            // EBMLMaxSizeLength
          }, {
            "data": "webm",
            "id": 17026
            // DocType
          }, {
            "data": 2,
            "id": 17031
            // DocTypeVersion
          }, {
            "data": 2,
            "id": 17029
            // DocTypeReadVersion
          }]
        }, {
          "id": 408125543,
          // Segment
          "data": [{
            "id": 357149030,
            // Info
            "data": [{
              "data": 1e6,
              //do things in millisecs (num of nanosecs for duration scale)
              "id": 2807729
              // TimecodeScale
            }, {
              "data": "whammy",
              "id": 19840
              // MuxingApp
            }, {
              "data": "whammy",
              "id": 22337
              // WritingApp
            }, {
              "data": doubleToString(info.duration),
              "id": 17545
              // Duration
            }]
          }, {
            "id": 374648427,
            // Tracks
            "data": [{
              "id": 174,
              // TrackEntry
              "data": [{
                "data": 1,
                "id": 215
                // TrackNumber
              }, {
                "data": 1,
                "id": 29637
                // TrackUID
              }, {
                "data": 0,
                "id": 156
                // FlagLacing
              }, {
                "data": "und",
                "id": 2274716
                // Language
              }, {
                "data": "V_VP8",
                "id": 134
                // CodecID
              }, {
                "data": "VP8",
                "id": 2459272
                // CodecName
              }, {
                "data": 1,
                "id": 131
                // TrackType
              }, {
                "id": 224,
                // Video
                "data": [{
                  "data": info.width,
                  "id": 176
                  // PixelWidth
                }, {
                  "data": info.height,
                  "id": 186
                  // PixelHeight
                }]
              }]
            }]
          }]
        }];
        var frameNumber = 0;
        var clusterTimecode = 0;
        while (frameNumber < frames2.length) {
          var clusterFrames = [];
          var clusterDuration = 0;
          do {
            clusterFrames.push(frames2[frameNumber]);
            clusterDuration += frames2[frameNumber].duration;
            frameNumber++;
          } while (frameNumber < frames2.length && clusterDuration < clusterMaxDuration);
          var clusterCounter = 0;
          var cluster = {
            "id": 524531317,
            // Cluster
            "data": getClusterData(clusterTimecode, clusterCounter, clusterFrames)
          };
          EBML2[1].data.push(cluster);
          clusterTimecode += clusterDuration;
        }
        return generateEBML(EBML2);
      }
      function getClusterData(clusterTimecode, clusterCounter, clusterFrames) {
        return [{
          "data": clusterTimecode,
          "id": 231
          // Timecode
        }].concat(clusterFrames.map(function(webp) {
          var block = makeSimpleBlock({
            discardable: 0,
            frame: webp.data.slice(4),
            invisible: 0,
            keyframe: 1,
            lacing: 0,
            trackNum: 1,
            timecode: Math.round(clusterCounter)
          });
          clusterCounter += webp.duration;
          return {
            data: block,
            id: 163
          };
        }));
      }
      function checkFrames(frames2) {
        if (!frames2[0]) {
          postMessage({
            error: "Something went wrong. Maybe WebP format is not supported in the current browser."
          });
          return;
        }
        var width = frames2[0].width, height = frames2[0].height, duration = frames2[0].duration;
        for (var i = 1; i < frames2.length; i++) {
          duration += frames2[i].duration;
        }
        return {
          duration,
          width,
          height
        };
      }
      function numToBuffer(num) {
        var parts = [];
        while (num > 0) {
          parts.push(num & 255);
          num = num >> 8;
        }
        return new Uint8Array(parts.reverse());
      }
      function strToBuffer(str) {
        return new Uint8Array(str.split("").map(function(e) {
          return e.charCodeAt(0);
        }));
      }
      function bitsToBuffer(bits) {
        var data = [];
        var pad = bits.length % 8 ? new Array(1 + 8 - bits.length % 8).join("0") : "";
        bits = pad + bits;
        for (var i = 0; i < bits.length; i += 8) {
          data.push(parseInt(bits.substr(i, 8), 2));
        }
        return new Uint8Array(data);
      }
      function generateEBML(json) {
        var ebml = [];
        for (var i = 0; i < json.length; i++) {
          var data = json[i].data;
          if (typeof data === "object") {
            data = generateEBML(data);
          }
          if (typeof data === "number") {
            data = bitsToBuffer(data.toString(2));
          }
          if (typeof data === "string") {
            data = strToBuffer(data);
          }
          var len = data.size || data.byteLength || data.length;
          var zeroes = Math.ceil(Math.ceil(Math.log(len) / Math.log(2)) / 8);
          var sizeToString = len.toString(2);
          var padded = new Array(zeroes * 7 + 7 + 1 - sizeToString.length).join("0") + sizeToString;
          var size = new Array(zeroes).join("0") + "1" + padded;
          ebml.push(numToBuffer(json[i].id));
          ebml.push(bitsToBuffer(size));
          ebml.push(data);
        }
        return new Blob(ebml, {
          type: "video/webm"
        });
      }
      function makeSimpleBlock(data) {
        var flags = 0;
        if (data.keyframe) {
          flags |= 128;
        }
        if (data.invisible) {
          flags |= 8;
        }
        if (data.lacing) {
          flags |= data.lacing << 1;
        }
        if (data.discardable) {
          flags |= 1;
        }
        if (data.trackNum > 127) {
          throw "TrackNumber > 127 not supported";
        }
        var out = [data.trackNum | 128, data.timecode >> 8, data.timecode & 255, flags].map(function(e) {
          return String.fromCharCode(e);
        }).join("") + data.frame;
        return out;
      }
      function parseWebP(riff) {
        var VP8 = riff.RIFF[0].WEBP[0];
        var frameStart = VP8.indexOf("*");
        for (var i = 0, c = []; i < 4; i++) {
          c[i] = VP8.charCodeAt(frameStart + 3 + i);
        }
        var width, height, tmp;
        tmp = c[1] << 8 | c[0];
        width = tmp & 16383;
        tmp = c[3] << 8 | c[2];
        height = tmp & 16383;
        return {
          width,
          height,
          data: VP8,
          riff
        };
      }
      function getStrLength(string, offset) {
        return parseInt(string.substr(offset + 4, 4).split("").map(function(i) {
          var unpadded = i.charCodeAt(0).toString(2);
          return new Array(8 - unpadded.length + 1).join("0") + unpadded;
        }).join(""), 2);
      }
      function parseRIFF(string) {
        var offset = 0;
        var chunks = {};
        while (offset < string.length) {
          var id = string.substr(offset, 4);
          var len = getStrLength(string, offset);
          var data = string.substr(offset + 4 + 4, len);
          offset += 4 + 4 + len;
          chunks[id] = chunks[id] || [];
          if (id === "RIFF" || id === "LIST") {
            chunks[id].push(parseRIFF(data));
          } else {
            chunks[id].push(data);
          }
        }
        return chunks;
      }
      function doubleToString(num) {
        return [].slice.call(
          new Uint8Array(new Float64Array([num]).buffer),
          0
        ).map(function(e) {
          return String.fromCharCode(e);
        }).reverse().join("");
      }
      var webm = new ArrayToWebM(frames.map(function(frame) {
        var webp = parseWebP(parseRIFF(atob(frame.image.slice(23))));
        webp.duration = frame.duration;
        return webp;
      }));
      postMessage(webm);
    }
    WhammyVideo.prototype.compile = function(callback) {
      var webWorker = processInWebWorker(whammyInWebWorker);
      webWorker.onmessage = function(event) {
        if (event.data.error) {
          console.error(event.data.error);
          return;
        }
        callback(event.data);
      };
      webWorker.postMessage(this.frames);
    };
    return {
      /**
       * A more abstract-ish API.
       * @method
       * @memberof Whammy
       * @example
       * recorder = new Whammy().Video(0.8, 100);
       * @param {?number} speed - 0.8
       * @param {?number} quality - 100
       */
      Video: WhammyVideo
    };
  }();
  if (typeof RecordRTC2 !== "undefined") {
    RecordRTC2.Whammy = Whammy;
  }
  /**
   * DiskStorage is a standalone object used by {@link RecordRTC} to store recorded blobs in IndexedDB storage.
   * @summary Writing blobs into IndexedDB.
   * @license {@link https://github.com/muaz-khan/RecordRTC/blob/master/LICENSE|MIT}
   * @author {@link https://MuazKhan.com|Muaz Khan}
   * @example
   * DiskStorage.Store({
   *     audioBlob: yourAudioBlob,
   *     videoBlob: yourVideoBlob,
   *     gifBlob  : yourGifBlob
   * });
   * DiskStorage.Fetch(function(dataURL, type) {
   *     if(type === 'audioBlob') { }
   *     if(type === 'videoBlob') { }
   *     if(type === 'gifBlob')   { }
   * });
   * // DiskStorage.dataStoreName = 'recordRTC';
   * // DiskStorage.onError = function(error) { };
   * @property {function} init - This method must be called once to initialize IndexedDB ObjectStore. Though, it is auto-used internally.
   * @property {function} Fetch - This method fetches stored blobs from IndexedDB.
   * @property {function} Store - This method stores blobs in IndexedDB.
   * @property {function} onError - This function is invoked for any known/unknown error.
   * @property {string} dataStoreName - Name of the ObjectStore created in IndexedDB storage.
   * @see {@link https://github.com/muaz-khan/RecordRTC|RecordRTC Source Code}
   */
  var DiskStorage = {
    /**
     * This method must be called once to initialize IndexedDB ObjectStore. Though, it is auto-used internally.
     * @method
     * @memberof DiskStorage
     * @internal
     * @example
     * DiskStorage.init();
     */
    init: function() {
      var self2 = this;
      if (typeof indexedDB === "undefined" || typeof indexedDB.open === "undefined") {
        console.error("IndexedDB API are not available in this browser.");
        return;
      }
      var dbVersion = 1;
      var dbName = this.dbName || location.href.replace(/\/|:|#|%|\.|\[|\]/g, ""), db;
      var request = indexedDB.open(dbName, dbVersion);
      function createObjectStore(dataBase) {
        dataBase.createObjectStore(self2.dataStoreName);
      }
      function putInDB() {
        var transaction = db.transaction([self2.dataStoreName], "readwrite");
        if (self2.videoBlob) {
          transaction.objectStore(self2.dataStoreName).put(self2.videoBlob, "videoBlob");
        }
        if (self2.gifBlob) {
          transaction.objectStore(self2.dataStoreName).put(self2.gifBlob, "gifBlob");
        }
        if (self2.audioBlob) {
          transaction.objectStore(self2.dataStoreName).put(self2.audioBlob, "audioBlob");
        }
        function getFromStore(portionName) {
          transaction.objectStore(self2.dataStoreName).get(portionName).onsuccess = function(event) {
            if (self2.callback) {
              self2.callback(event.target.result, portionName);
            }
          };
        }
        getFromStore("audioBlob");
        getFromStore("videoBlob");
        getFromStore("gifBlob");
      }
      request.onerror = self2.onError;
      request.onsuccess = function() {
        db = request.result;
        db.onerror = self2.onError;
        if (db.setVersion) {
          if (db.version !== dbVersion) {
            var setVersion = db.setVersion(dbVersion);
            setVersion.onsuccess = function() {
              createObjectStore(db);
              putInDB();
            };
          } else {
            putInDB();
          }
        } else {
          putInDB();
        }
      };
      request.onupgradeneeded = function(event) {
        createObjectStore(event.target.result);
      };
    },
    /**
     * This method fetches stored blobs from IndexedDB.
     * @method
     * @memberof DiskStorage
     * @internal
     * @example
     * DiskStorage.Fetch(function(dataURL, type) {
     *     if(type === 'audioBlob') { }
     *     if(type === 'videoBlob') { }
     *     if(type === 'gifBlob')   { }
     * });
     */
    Fetch: function(callback) {
      this.callback = callback;
      this.init();
      return this;
    },
    /**
     * This method stores blobs in IndexedDB.
     * @method
     * @memberof DiskStorage
     * @internal
     * @example
     * DiskStorage.Store({
     *     audioBlob: yourAudioBlob,
     *     videoBlob: yourVideoBlob,
     *     gifBlob  : yourGifBlob
     * });
     */
    Store: function(config) {
      this.audioBlob = config.audioBlob;
      this.videoBlob = config.videoBlob;
      this.gifBlob = config.gifBlob;
      this.init();
      return this;
    },
    /**
     * This function is invoked for any known/unknown error.
     * @method
     * @memberof DiskStorage
     * @internal
     * @example
     * DiskStorage.onError = function(error){
     *     alerot( JSON.stringify(error) );
     * };
     */
    onError: function(error) {
      console.error(JSON.stringify(error, null, "	"));
    },
    /**
     * @property {string} dataStoreName - Name of the ObjectStore created in IndexedDB storage.
     * @memberof DiskStorage
     * @internal
     * @example
     * DiskStorage.dataStoreName = 'recordRTC';
     */
    dataStoreName: "recordRTC",
    dbName: null
  };
  if (typeof RecordRTC2 !== "undefined") {
    RecordRTC2.DiskStorage = DiskStorage;
  }
  /**
   * GifRecorder is standalone calss used by {@link RecordRTC} to record video or canvas into animated gif.
   * @license {@link https://github.com/muaz-khan/RecordRTC/blob/master/LICENSE|MIT}
   * @author {@link https://MuazKhan.com|Muaz Khan}
   * @typedef GifRecorder
   * @class
   * @example
   * var recorder = new GifRecorder(mediaStream || canvas || context, { onGifPreview: function, onGifRecordingStarted: function, width: 1280, height: 720, frameRate: 200, quality: 10 });
   * recorder.record();
   * recorder.stop(function(blob) {
   *     img.src = URL.createObjectURL(blob);
   * });
   * @see {@link https://github.com/muaz-khan/RecordRTC|RecordRTC Source Code}
   * @param {MediaStream} mediaStream - MediaStream object or HTMLCanvasElement or CanvasRenderingContext2D.
   * @param {object} config - {disableLogs:true, initCallback: function, width: 320, height: 240, frameRate: 200, quality: 10}
   */
  function GifRecorder(mediaStream, config) {
    if (typeof GIFEncoder === "undefined") {
      var script = document.createElement("script");
      script.src = "https://www.webrtc-experiment.com/gif-recorder.js";
      (document.body || document.documentElement).appendChild(script);
    }
    config = config || {};
    var isHTMLObject = mediaStream instanceof CanvasRenderingContext2D || mediaStream instanceof HTMLCanvasElement;
    this.record = function() {
      if (typeof GIFEncoder === "undefined") {
        setTimeout(self2.record, 1e3);
        return;
      }
      if (!isLoadedMetaData) {
        setTimeout(self2.record, 1e3);
        return;
      }
      if (!isHTMLObject) {
        if (!config.width) {
          config.width = video.offsetWidth || 320;
        }
        if (!config.height) {
          config.height = video.offsetHeight || 240;
        }
        if (!config.video) {
          config.video = {
            width: config.width,
            height: config.height
          };
        }
        if (!config.canvas) {
          config.canvas = {
            width: config.width,
            height: config.height
          };
        }
        canvas.width = config.canvas.width || 320;
        canvas.height = config.canvas.height || 240;
        video.width = config.video.width || 320;
        video.height = config.video.height || 240;
      }
      gifEncoder = new GIFEncoder();
      gifEncoder.setRepeat(0);
      gifEncoder.setDelay(config.frameRate || 200);
      gifEncoder.setQuality(config.quality || 10);
      gifEncoder.start();
      if (typeof config.onGifRecordingStarted === "function") {
        config.onGifRecordingStarted();
      }
      function drawVideoFrame(time) {
        if (self2.clearedRecordedData === true) {
          return;
        }
        if (isPausedRecording) {
          return setTimeout(function() {
            drawVideoFrame(time);
          }, 100);
        }
        lastAnimationFrame = requestAnimationFrame2(drawVideoFrame);
        if (typeof lastFrameTime === void 0) {
          lastFrameTime = time;
        }
        if (time - lastFrameTime < 90) {
          return;
        }
        if (!isHTMLObject && video.paused) {
          video.play();
        }
        if (!isHTMLObject) {
          context.drawImage(video, 0, 0, canvas.width, canvas.height);
        }
        if (config.onGifPreview) {
          config.onGifPreview(canvas.toDataURL("image/png"));
        }
        gifEncoder.addFrame(context);
        lastFrameTime = time;
      }
      lastAnimationFrame = requestAnimationFrame2(drawVideoFrame);
      if (config.initCallback) {
        config.initCallback();
      }
    };
    this.stop = function(callback) {
      callback = callback || function() {
      };
      if (lastAnimationFrame) {
        cancelAnimationFrame2(lastAnimationFrame);
      }
      this.blob = new Blob([new Uint8Array(gifEncoder.stream().bin)], {
        type: "image/gif"
      });
      callback(this.blob);
      gifEncoder.stream().bin = [];
    };
    var isPausedRecording = false;
    this.pause = function() {
      isPausedRecording = true;
    };
    this.resume = function() {
      isPausedRecording = false;
    };
    this.clearRecordedData = function() {
      self2.clearedRecordedData = true;
      clearRecordedDataCB();
    };
    function clearRecordedDataCB() {
      if (gifEncoder) {
        gifEncoder.stream().bin = [];
      }
    }
    this.name = "GifRecorder";
    this.toString = function() {
      return this.name;
    };
    var canvas = document.createElement("canvas");
    var context = canvas.getContext("2d");
    if (isHTMLObject) {
      if (mediaStream instanceof CanvasRenderingContext2D) {
        context = mediaStream;
        canvas = context.canvas;
      } else if (mediaStream instanceof HTMLCanvasElement) {
        context = mediaStream.getContext("2d");
        canvas = mediaStream;
      }
    }
    var isLoadedMetaData = true;
    if (!isHTMLObject) {
      var video = document.createElement("video");
      video.muted = true;
      video.autoplay = true;
      video.playsInline = true;
      isLoadedMetaData = false;
      video.onloadedmetadata = function() {
        isLoadedMetaData = true;
      };
      setSrcObject(mediaStream, video);
      video.play();
    }
    var lastAnimationFrame = null;
    var lastFrameTime;
    var gifEncoder;
    var self2 = this;
  }
  if (typeof RecordRTC2 !== "undefined") {
    RecordRTC2.GifRecorder = GifRecorder;
  }
  function MultiStreamsMixer(arrayOfMediaStreams, elementClass) {
    var browserFakeUserAgent2 = "Fake/5.0 (FakeOS) AppleWebKit/123 (KHTML, like Gecko) Fake/12.3.4567.89 Fake/123.45";
    (function(that) {
      if (typeof RecordRTC2 !== "undefined") {
        return;
      }
      if (!that) {
        return;
      }
      if (typeof window !== "undefined") {
        return;
      }
      if (typeof commonjsGlobal === "undefined") {
        return;
      }
      commonjsGlobal.navigator = {
        userAgent: browserFakeUserAgent2,
        getUserMedia: function() {
        }
      };
      if (!commonjsGlobal.console) {
        commonjsGlobal.console = {};
      }
      if (typeof commonjsGlobal.console.log === "undefined" || typeof commonjsGlobal.console.error === "undefined") {
        commonjsGlobal.console.error = commonjsGlobal.console.log = commonjsGlobal.console.log || function() {
          console.log(arguments);
        };
      }
      if (typeof document === "undefined") {
        that.document = {
          documentElement: {
            appendChild: function() {
              return "";
            }
          }
        };
        document.createElement = document.captureStream = document.mozCaptureStream = function() {
          var obj = {
            getContext: function() {
              return obj;
            },
            play: function() {
            },
            pause: function() {
            },
            drawImage: function() {
            },
            toDataURL: function() {
              return "";
            },
            style: {}
          };
          return obj;
        };
        that.HTMLVideoElement = function() {
        };
      }
      if (typeof location === "undefined") {
        that.location = {
          protocol: "file:",
          href: "",
          hash: ""
        };
      }
      if (typeof screen === "undefined") {
        that.screen = {
          width: 0,
          height: 0
        };
      }
      if (typeof URL2 === "undefined") {
        that.URL = {
          createObjectURL: function() {
            return "";
          },
          revokeObjectURL: function() {
            return "";
          }
        };
      }
      that.window = commonjsGlobal;
    })(typeof commonjsGlobal !== "undefined" ? commonjsGlobal : null);
    elementClass = elementClass || "multi-streams-mixer";
    var videos = [];
    var isStopDrawingFrames = false;
    var canvas = document.createElement("canvas");
    var context = canvas.getContext("2d");
    canvas.style.opacity = 0;
    canvas.style.position = "absolute";
    canvas.style.zIndex = -1;
    canvas.style.top = "-1000em";
    canvas.style.left = "-1000em";
    canvas.className = elementClass;
    (document.body || document.documentElement).appendChild(canvas);
    this.disableLogs = false;
    this.frameInterval = 10;
    this.width = 360;
    this.height = 240;
    this.useGainNode = true;
    var self2 = this;
    var AudioContext2 = window.AudioContext;
    if (typeof AudioContext2 === "undefined") {
      if (typeof webkitAudioContext !== "undefined") {
        AudioContext2 = webkitAudioContext;
      }
      if (typeof mozAudioContext !== "undefined") {
        AudioContext2 = mozAudioContext;
      }
    }
    var URL2 = window.URL;
    if (typeof URL2 === "undefined" && typeof webkitURL !== "undefined") {
      URL2 = webkitURL;
    }
    if (typeof navigator !== "undefined" && typeof navigator.getUserMedia === "undefined") {
      if (typeof navigator.webkitGetUserMedia !== "undefined") {
        navigator.getUserMedia = navigator.webkitGetUserMedia;
      }
      if (typeof navigator.mozGetUserMedia !== "undefined") {
        navigator.getUserMedia = navigator.mozGetUserMedia;
      }
    }
    var MediaStream2 = window.MediaStream;
    if (typeof MediaStream2 === "undefined" && typeof webkitMediaStream !== "undefined") {
      MediaStream2 = webkitMediaStream;
    }
    if (typeof MediaStream2 !== "undefined") {
      if (typeof MediaStream2.prototype.stop === "undefined") {
        MediaStream2.prototype.stop = function() {
          this.getTracks().forEach(function(track) {
            track.stop();
          });
        };
      }
    }
    var Storage2 = {};
    if (typeof AudioContext2 !== "undefined") {
      Storage2.AudioContext = AudioContext2;
    } else if (typeof webkitAudioContext !== "undefined") {
      Storage2.AudioContext = webkitAudioContext;
    }
    function setSrcObject2(stream, element) {
      if ("srcObject" in element) {
        element.srcObject = stream;
      } else if ("mozSrcObject" in element) {
        element.mozSrcObject = stream;
      } else {
        element.srcObject = stream;
      }
    }
    this.startDrawingFrames = function() {
      drawVideosToCanvas();
    };
    function drawVideosToCanvas() {
      if (isStopDrawingFrames) {
        return;
      }
      var videosLength = videos.length;
      var fullcanvas = false;
      var remaining = [];
      videos.forEach(function(video) {
        if (!video.stream) {
          video.stream = {};
        }
        if (video.stream.fullcanvas) {
          fullcanvas = video;
        } else {
          remaining.push(video);
        }
      });
      if (fullcanvas) {
        canvas.width = fullcanvas.stream.width;
        canvas.height = fullcanvas.stream.height;
      } else if (remaining.length) {
        canvas.width = videosLength > 1 ? remaining[0].width * 2 : remaining[0].width;
        var height = 1;
        if (videosLength === 3 || videosLength === 4) {
          height = 2;
        }
        if (videosLength === 5 || videosLength === 6) {
          height = 3;
        }
        if (videosLength === 7 || videosLength === 8) {
          height = 4;
        }
        if (videosLength === 9 || videosLength === 10) {
          height = 5;
        }
        canvas.height = remaining[0].height * height;
      } else {
        canvas.width = self2.width || 360;
        canvas.height = self2.height || 240;
      }
      if (fullcanvas && fullcanvas instanceof HTMLVideoElement) {
        drawImage(fullcanvas);
      }
      remaining.forEach(function(video, idx) {
        drawImage(video, idx);
      });
      setTimeout(drawVideosToCanvas, self2.frameInterval);
    }
    function drawImage(video, idx) {
      if (isStopDrawingFrames) {
        return;
      }
      var x = 0;
      var y = 0;
      var width = video.width;
      var height = video.height;
      if (idx === 1) {
        x = video.width;
      }
      if (idx === 2) {
        y = video.height;
      }
      if (idx === 3) {
        x = video.width;
        y = video.height;
      }
      if (idx === 4) {
        y = video.height * 2;
      }
      if (idx === 5) {
        x = video.width;
        y = video.height * 2;
      }
      if (idx === 6) {
        y = video.height * 3;
      }
      if (idx === 7) {
        x = video.width;
        y = video.height * 3;
      }
      if (typeof video.stream.left !== "undefined") {
        x = video.stream.left;
      }
      if (typeof video.stream.top !== "undefined") {
        y = video.stream.top;
      }
      if (typeof video.stream.width !== "undefined") {
        width = video.stream.width;
      }
      if (typeof video.stream.height !== "undefined") {
        height = video.stream.height;
      }
      context.drawImage(video, x, y, width, height);
      if (typeof video.stream.onRender === "function") {
        video.stream.onRender(context, x, y, width, height, idx);
      }
    }
    function getMixedStream() {
      isStopDrawingFrames = false;
      var mixedVideoStream = getMixedVideoStream();
      var mixedAudioStream = getMixedAudioStream();
      if (mixedAudioStream) {
        mixedAudioStream.getTracks().filter(function(t) {
          return t.kind === "audio";
        }).forEach(function(track) {
          mixedVideoStream.addTrack(track);
        });
      }
      arrayOfMediaStreams.forEach(function(stream) {
        if (stream.fullcanvas)
          ;
      });
      return mixedVideoStream;
    }
    function getMixedVideoStream() {
      resetVideoStreams();
      var capturedStream;
      if ("captureStream" in canvas) {
        capturedStream = canvas.captureStream();
      } else if ("mozCaptureStream" in canvas) {
        capturedStream = canvas.mozCaptureStream();
      } else if (!self2.disableLogs) {
        console.error("Upgrade to latest Chrome or otherwise enable this flag: chrome://flags/#enable-experimental-web-platform-features");
      }
      var videoStream = new MediaStream2();
      capturedStream.getTracks().filter(function(t) {
        return t.kind === "video";
      }).forEach(function(track) {
        videoStream.addTrack(track);
      });
      canvas.stream = videoStream;
      return videoStream;
    }
    function getMixedAudioStream() {
      if (!Storage2.AudioContextConstructor) {
        Storage2.AudioContextConstructor = new Storage2.AudioContext();
      }
      self2.audioContext = Storage2.AudioContextConstructor;
      self2.audioSources = [];
      if (self2.useGainNode === true) {
        self2.gainNode = self2.audioContext.createGain();
        self2.gainNode.connect(self2.audioContext.destination);
        self2.gainNode.gain.value = 0;
      }
      var audioTracksLength = 0;
      arrayOfMediaStreams.forEach(function(stream) {
        if (!stream.getTracks().filter(function(t) {
          return t.kind === "audio";
        }).length) {
          return;
        }
        audioTracksLength++;
        var audioSource = self2.audioContext.createMediaStreamSource(stream);
        if (self2.useGainNode === true) {
          audioSource.connect(self2.gainNode);
        }
        self2.audioSources.push(audioSource);
      });
      if (!audioTracksLength) {
        return;
      }
      self2.audioDestination = self2.audioContext.createMediaStreamDestination();
      self2.audioSources.forEach(function(audioSource) {
        audioSource.connect(self2.audioDestination);
      });
      return self2.audioDestination.stream;
    }
    function getVideo(stream) {
      var video = document.createElement("video");
      setSrcObject2(stream, video);
      video.className = elementClass;
      video.muted = true;
      video.volume = 0;
      video.width = stream.width || self2.width || 360;
      video.height = stream.height || self2.height || 240;
      video.play();
      return video;
    }
    this.appendStreams = function(streams) {
      if (!streams) {
        throw "First parameter is required.";
      }
      if (!(streams instanceof Array)) {
        streams = [streams];
      }
      streams.forEach(function(stream) {
        var newStream = new MediaStream2();
        if (stream.getTracks().filter(function(t) {
          return t.kind === "video";
        }).length) {
          var video = getVideo(stream);
          video.stream = stream;
          videos.push(video);
          newStream.addTrack(stream.getTracks().filter(function(t) {
            return t.kind === "video";
          })[0]);
        }
        if (stream.getTracks().filter(function(t) {
          return t.kind === "audio";
        }).length) {
          var audioSource = self2.audioContext.createMediaStreamSource(stream);
          self2.audioDestination = self2.audioContext.createMediaStreamDestination();
          audioSource.connect(self2.audioDestination);
          newStream.addTrack(self2.audioDestination.stream.getTracks().filter(function(t) {
            return t.kind === "audio";
          })[0]);
        }
        arrayOfMediaStreams.push(newStream);
      });
    };
    this.releaseStreams = function() {
      videos = [];
      isStopDrawingFrames = true;
      if (self2.gainNode) {
        self2.gainNode.disconnect();
        self2.gainNode = null;
      }
      if (self2.audioSources.length) {
        self2.audioSources.forEach(function(source) {
          source.disconnect();
        });
        self2.audioSources = [];
      }
      if (self2.audioDestination) {
        self2.audioDestination.disconnect();
        self2.audioDestination = null;
      }
      if (self2.audioContext) {
        self2.audioContext.close();
      }
      self2.audioContext = null;
      context.clearRect(0, 0, canvas.width, canvas.height);
      if (canvas.stream) {
        canvas.stream.stop();
        canvas.stream = null;
      }
    };
    this.resetVideoStreams = function(streams) {
      if (streams && !(streams instanceof Array)) {
        streams = [streams];
      }
      resetVideoStreams(streams);
    };
    function resetVideoStreams(streams) {
      videos = [];
      streams = streams || arrayOfMediaStreams;
      streams.forEach(function(stream) {
        if (!stream.getTracks().filter(function(t) {
          return t.kind === "video";
        }).length) {
          return;
        }
        var video = getVideo(stream);
        video.stream = stream;
        videos.push(video);
      });
    }
    this.name = "MultiStreamsMixer";
    this.toString = function() {
      return this.name;
    };
    this.getMixedStream = getMixedStream;
  }
  if (typeof RecordRTC2 === "undefined") {
    {
      module.exports = MultiStreamsMixer;
    }
  }
  /**
   * MultiStreamRecorder can record multiple videos in single container.
   * @summary Multi-videos recorder.
   * @license {@link https://github.com/muaz-khan/RecordRTC/blob/master/LICENSE|MIT}
   * @author {@link https://MuazKhan.com|Muaz Khan}
   * @typedef MultiStreamRecorder
   * @class
   * @example
   * var options = {
   *     mimeType: 'video/webm'
   * }
   * var recorder = new MultiStreamRecorder(ArrayOfMediaStreams, options);
   * recorder.record();
   * recorder.stop(function(blob) {
   *     video.src = URL.createObjectURL(blob);
   *
   *     // or
   *     var blob = recorder.blob;
   * });
   * @see {@link https://github.com/muaz-khan/RecordRTC|RecordRTC Source Code}
   * @param {MediaStreams} mediaStreams - Array of MediaStreams.
   * @param {object} config - {disableLogs:true, frameInterval: 1, mimeType: "video/webm"}
   */
  function MultiStreamRecorder(arrayOfMediaStreams, options) {
    arrayOfMediaStreams = arrayOfMediaStreams || [];
    var self2 = this;
    var mixer;
    var mediaRecorder;
    options = options || {
      elementClass: "multi-streams-mixer",
      mimeType: "video/webm",
      video: {
        width: 360,
        height: 240
      }
    };
    if (!options.frameInterval) {
      options.frameInterval = 10;
    }
    if (!options.video) {
      options.video = {};
    }
    if (!options.video.width) {
      options.video.width = 360;
    }
    if (!options.video.height) {
      options.video.height = 240;
    }
    this.record = function() {
      mixer = new MultiStreamsMixer(arrayOfMediaStreams, options.elementClass || "multi-streams-mixer");
      if (getAllVideoTracks().length) {
        mixer.frameInterval = options.frameInterval || 10;
        mixer.width = options.video.width || 360;
        mixer.height = options.video.height || 240;
        mixer.startDrawingFrames();
      }
      if (options.previewStream && typeof options.previewStream === "function") {
        options.previewStream(mixer.getMixedStream());
      }
      mediaRecorder = new MediaStreamRecorder(mixer.getMixedStream(), options);
      mediaRecorder.record();
    };
    function getAllVideoTracks() {
      var tracks = [];
      arrayOfMediaStreams.forEach(function(stream) {
        getTracks(stream, "video").forEach(function(track) {
          tracks.push(track);
        });
      });
      return tracks;
    }
    this.stop = function(callback) {
      if (!mediaRecorder) {
        return;
      }
      mediaRecorder.stop(function(blob) {
        self2.blob = blob;
        callback(blob);
        self2.clearRecordedData();
      });
    };
    this.pause = function() {
      if (mediaRecorder) {
        mediaRecorder.pause();
      }
    };
    this.resume = function() {
      if (mediaRecorder) {
        mediaRecorder.resume();
      }
    };
    this.clearRecordedData = function() {
      if (mediaRecorder) {
        mediaRecorder.clearRecordedData();
        mediaRecorder = null;
      }
      if (mixer) {
        mixer.releaseStreams();
        mixer = null;
      }
    };
    this.addStreams = function(streams) {
      if (!streams) {
        throw "First parameter is required.";
      }
      if (!(streams instanceof Array)) {
        streams = [streams];
      }
      arrayOfMediaStreams.concat(streams);
      if (!mediaRecorder || !mixer) {
        return;
      }
      mixer.appendStreams(streams);
      if (options.previewStream && typeof options.previewStream === "function") {
        options.previewStream(mixer.getMixedStream());
      }
    };
    this.resetVideoStreams = function(streams) {
      if (!mixer) {
        return;
      }
      if (streams && !(streams instanceof Array)) {
        streams = [streams];
      }
      mixer.resetVideoStreams(streams);
    };
    this.getMixer = function() {
      return mixer;
    };
    this.name = "MultiStreamRecorder";
    this.toString = function() {
      return this.name;
    };
  }
  if (typeof RecordRTC2 !== "undefined") {
    RecordRTC2.MultiStreamRecorder = MultiStreamRecorder;
  }
  /**
   * RecordRTCPromisesHandler adds promises support in {@link RecordRTC}. Try a {@link https://github.com/muaz-khan/RecordRTC/blob/master/simple-demos/RecordRTCPromisesHandler.html|demo here}
   * @summary Promises for {@link RecordRTC}
   * @license {@link https://github.com/muaz-khan/RecordRTC/blob/master/LICENSE|MIT}
   * @author {@link https://MuazKhan.com|Muaz Khan}
   * @typedef RecordRTCPromisesHandler
   * @class
   * @example
   * var recorder = new RecordRTCPromisesHandler(mediaStream, options);
   * recorder.startRecording()
   *         .then(successCB)
   *         .catch(errorCB);
   * // Note: You can access all RecordRTC API using "recorder.recordRTC" e.g. 
   * recorder.recordRTC.onStateChanged = function(state) {};
   * recorder.recordRTC.setRecordingDuration(5000);
   * @see {@link https://github.com/muaz-khan/RecordRTC|RecordRTC Source Code}
   * @param {MediaStream} mediaStream - Single media-stream object, array of media-streams, html-canvas-element, etc.
   * @param {object} config - {type:"video", recorderType: MediaStreamRecorder, disableLogs: true, numberOfAudioChannels: 1, bufferSize: 0, sampleRate: 0, video: HTMLVideoElement, etc.}
   * @throws Will throw an error if "new" keyword is not used to initiate "RecordRTCPromisesHandler". Also throws error if first argument "MediaStream" is missing.
   * @requires {@link RecordRTC}
   */
  function RecordRTCPromisesHandler(mediaStream, options) {
    if (!this) {
      throw 'Use "new RecordRTCPromisesHandler()"';
    }
    if (typeof mediaStream === "undefined") {
      throw 'First argument "MediaStream" is required.';
    }
    var self2 = this;
    self2.recordRTC = new RecordRTC2(mediaStream, options);
    this.startRecording = function() {
      return new Promise(function(resolve, reject) {
        try {
          self2.recordRTC.startRecording();
          resolve();
        } catch (e) {
          reject(e);
        }
      });
    };
    this.stopRecording = function() {
      return new Promise(function(resolve, reject) {
        try {
          self2.recordRTC.stopRecording(function(url) {
            self2.blob = self2.recordRTC.getBlob();
            if (!self2.blob || !self2.blob.size) {
              reject("Empty blob.", self2.blob);
              return;
            }
            resolve(url);
          });
        } catch (e) {
          reject(e);
        }
      });
    };
    this.pauseRecording = function() {
      return new Promise(function(resolve, reject) {
        try {
          self2.recordRTC.pauseRecording();
          resolve();
        } catch (e) {
          reject(e);
        }
      });
    };
    this.resumeRecording = function() {
      return new Promise(function(resolve, reject) {
        try {
          self2.recordRTC.resumeRecording();
          resolve();
        } catch (e) {
          reject(e);
        }
      });
    };
    this.getDataURL = function(callback) {
      return new Promise(function(resolve, reject) {
        try {
          self2.recordRTC.getDataURL(function(dataURL) {
            resolve(dataURL);
          });
        } catch (e) {
          reject(e);
        }
      });
    };
    this.getBlob = function() {
      return new Promise(function(resolve, reject) {
        try {
          resolve(self2.recordRTC.getBlob());
        } catch (e) {
          reject(e);
        }
      });
    };
    this.getInternalRecorder = function() {
      return new Promise(function(resolve, reject) {
        try {
          resolve(self2.recordRTC.getInternalRecorder());
        } catch (e) {
          reject(e);
        }
      });
    };
    this.reset = function() {
      return new Promise(function(resolve, reject) {
        try {
          resolve(self2.recordRTC.reset());
        } catch (e) {
          reject(e);
        }
      });
    };
    this.destroy = function() {
      return new Promise(function(resolve, reject) {
        try {
          resolve(self2.recordRTC.destroy());
        } catch (e) {
          reject(e);
        }
      });
    };
    this.getState = function() {
      return new Promise(function(resolve, reject) {
        try {
          resolve(self2.recordRTC.getState());
        } catch (e) {
          reject(e);
        }
      });
    };
    this.blob = null;
    this.version = "5.6.2";
  }
  if (typeof RecordRTC2 !== "undefined") {
    RecordRTC2.RecordRTCPromisesHandler = RecordRTCPromisesHandler;
  }
  /**
   * WebAssemblyRecorder lets you create webm videos in JavaScript via WebAssembly. The library consumes raw RGBA32 buffers (4 bytes per pixel) and turns them into a webm video with the given framerate and quality. This makes it compatible out-of-the-box with ImageData from a CANVAS. With realtime mode you can also use webm-wasm for streaming webm videos.
   * @summary Video recording feature in Chrome, Firefox and maybe Edge.
   * @license {@link https://github.com/muaz-khan/RecordRTC/blob/master/LICENSE|MIT}
   * @author {@link https://MuazKhan.com|Muaz Khan}
   * @typedef WebAssemblyRecorder
   * @class
   * @example
   * var recorder = new WebAssemblyRecorder(mediaStream);
   * recorder.record();
   * recorder.stop(function(blob) {
   *     video.src = URL.createObjectURL(blob);
   * });
   * @see {@link https://github.com/muaz-khan/RecordRTC|RecordRTC Source Code}
   * @param {MediaStream} mediaStream - MediaStream object fetched using getUserMedia API or generated using captureStreamUntilEnded or WebAudio API.
   * @param {object} config - {webAssemblyPath:'webm-wasm.wasm',workerPath: 'webm-worker.js', frameRate: 30, width: 1920, height: 1080, bitrate: 1024, realtime: true}
   */
  function WebAssemblyRecorder(stream, config) {
    if (typeof ReadableStream === "undefined" || typeof WritableStream === "undefined") {
      console.error("Following polyfill is strongly recommended: https://unpkg.com/@mattiasbuelens/web-streams-polyfill/dist/polyfill.min.js");
    }
    config = config || {};
    config.width = config.width || 640;
    config.height = config.height || 480;
    config.frameRate = config.frameRate || 30;
    config.bitrate = config.bitrate || 1200;
    config.realtime = config.realtime || true;
    var finished;
    function cameraStream() {
      return new ReadableStream({
        start: function(controller) {
          var cvs = document.createElement("canvas");
          var video = document.createElement("video");
          var first = true;
          video.srcObject = stream;
          video.muted = true;
          video.height = config.height;
          video.width = config.width;
          video.volume = 0;
          video.onplaying = function() {
            cvs.width = config.width;
            cvs.height = config.height;
            var ctx = cvs.getContext("2d");
            var frameTimeout = 1e3 / config.frameRate;
            var cameraTimer = setInterval(function f() {
              if (finished) {
                clearInterval(cameraTimer);
                controller.close();
              }
              if (first) {
                first = false;
                if (config.onVideoProcessStarted) {
                  config.onVideoProcessStarted();
                }
              }
              ctx.drawImage(video, 0, 0);
              if (controller._controlledReadableStream.state !== "closed") {
                try {
                  controller.enqueue(
                    ctx.getImageData(0, 0, config.width, config.height)
                  );
                } catch (e) {
                }
              }
            }, frameTimeout);
          };
          video.play();
        }
      });
    }
    var worker;
    function startRecording(stream2, buffer) {
      if (!config.workerPath && !buffer) {
        finished = false;
        fetch(
          "https://unpkg.com/webm-wasm@latest/dist/webm-worker.js"
        ).then(function(r) {
          r.arrayBuffer().then(function(buffer2) {
            startRecording(stream2, buffer2);
          });
        });
        return;
      }
      if (!config.workerPath && buffer instanceof ArrayBuffer) {
        var blob = new Blob([buffer], {
          type: "text/javascript"
        });
        config.workerPath = URL.createObjectURL(blob);
      }
      if (!config.workerPath) {
        console.error("workerPath parameter is missing.");
      }
      worker = new Worker(config.workerPath);
      worker.postMessage(config.webAssemblyPath || "https://unpkg.com/webm-wasm@latest/dist/webm-wasm.wasm");
      worker.addEventListener("message", function(event) {
        if (event.data === "READY") {
          worker.postMessage({
            width: config.width,
            height: config.height,
            bitrate: config.bitrate || 1200,
            timebaseDen: config.frameRate || 30,
            realtime: config.realtime
          });
          cameraStream().pipeTo(new WritableStream({
            write: function(image) {
              if (finished) {
                console.error("Got image, but recorder is finished!");
                return;
              }
              worker.postMessage(image.data.buffer, [image.data.buffer]);
            }
          }));
        } else if (!!event.data) {
          if (!isPaused) {
            arrayOfBuffers.push(event.data);
          }
        }
      });
    }
    this.record = function() {
      arrayOfBuffers = [];
      isPaused = false;
      this.blob = null;
      startRecording(stream);
      if (typeof config.initCallback === "function") {
        config.initCallback();
      }
    };
    var isPaused;
    this.pause = function() {
      isPaused = true;
    };
    this.resume = function() {
      isPaused = false;
    };
    function terminate(callback) {
      if (!worker) {
        if (callback) {
          callback();
        }
        return;
      }
      worker.addEventListener("message", function(event) {
        if (event.data === null) {
          worker.terminate();
          worker = null;
          if (callback) {
            callback();
          }
        }
      });
      worker.postMessage(null);
    }
    var arrayOfBuffers = [];
    this.stop = function(callback) {
      finished = true;
      var recorder = this;
      terminate(function() {
        recorder.blob = new Blob(arrayOfBuffers, {
          type: "video/webm"
        });
        callback(recorder.blob);
      });
    };
    this.name = "WebAssemblyRecorder";
    this.toString = function() {
      return this.name;
    };
    this.clearRecordedData = function() {
      arrayOfBuffers = [];
      isPaused = false;
      this.blob = null;
    };
    this.blob = null;
  }
  if (typeof RecordRTC2 !== "undefined") {
    RecordRTC2.WebAssemblyRecorder = WebAssemblyRecorder;
  }
})(RecordRTC$1);
var RecordRTCExports = RecordRTC$1.exports;
const RecordRTC = /* @__PURE__ */ getDefaultExportFromCjs(RecordRTCExports);
function bind(fn, thisArg) {
  return function wrap() {
    return fn.apply(thisArg, arguments);
  };
}
const { toString } = Object.prototype;
const { getPrototypeOf } = Object;
const kindOf = /* @__PURE__ */ ((cache) => (thing) => {
  const str = toString.call(thing);
  return cache[str] || (cache[str] = str.slice(8, -1).toLowerCase());
})(/* @__PURE__ */ Object.create(null));
const kindOfTest = (type) => {
  type = type.toLowerCase();
  return (thing) => kindOf(thing) === type;
};
const typeOfTest = (type) => (thing) => typeof thing === type;
const { isArray } = Array;
const isUndefined = typeOfTest("undefined");
function isBuffer(val) {
  return val !== null && !isUndefined(val) && val.constructor !== null && !isUndefined(val.constructor) && isFunction(val.constructor.isBuffer) && val.constructor.isBuffer(val);
}
const isArrayBuffer = kindOfTest("ArrayBuffer");
function isArrayBufferView(val) {
  let result;
  if (typeof ArrayBuffer !== "undefined" && ArrayBuffer.isView) {
    result = ArrayBuffer.isView(val);
  } else {
    result = val && val.buffer && isArrayBuffer(val.buffer);
  }
  return result;
}
const isString = typeOfTest("string");
const isFunction = typeOfTest("function");
const isNumber = typeOfTest("number");
const isObject = (thing) => thing !== null && typeof thing === "object";
const isBoolean = (thing) => thing === true || thing === false;
const isPlainObject = (val) => {
  if (kindOf(val) !== "object") {
    return false;
  }
  const prototype2 = getPrototypeOf(val);
  return (prototype2 === null || prototype2 === Object.prototype || Object.getPrototypeOf(prototype2) === null) && !(Symbol.toStringTag in val) && !(Symbol.iterator in val);
};
const isDate = kindOfTest("Date");
const isFile = kindOfTest("File");
const isBlob = kindOfTest("Blob");
const isFileList = kindOfTest("FileList");
const isStream = (val) => isObject(val) && isFunction(val.pipe);
const isFormData = (thing) => {
  let kind;
  return thing && (typeof FormData === "function" && thing instanceof FormData || isFunction(thing.append) && ((kind = kindOf(thing)) === "formdata" || // detect form-data instance
  kind === "object" && isFunction(thing.toString) && thing.toString() === "[object FormData]"));
};
const isURLSearchParams = kindOfTest("URLSearchParams");
const trim = (str) => str.trim ? str.trim() : str.replace(/^[\s\uFEFF\xA0]+|[\s\uFEFF\xA0]+$/g, "");
function forEach(obj, fn, { allOwnKeys = false } = {}) {
  if (obj === null || typeof obj === "undefined") {
    return;
  }
  let i;
  let l;
  if (typeof obj !== "object") {
    obj = [obj];
  }
  if (isArray(obj)) {
    for (i = 0, l = obj.length; i < l; i++) {
      fn.call(null, obj[i], i, obj);
    }
  } else {
    const keys = allOwnKeys ? Object.getOwnPropertyNames(obj) : Object.keys(obj);
    const len = keys.length;
    let key;
    for (i = 0; i < len; i++) {
      key = keys[i];
      fn.call(null, obj[key], key, obj);
    }
  }
}
function findKey(obj, key) {
  key = key.toLowerCase();
  const keys = Object.keys(obj);
  let i = keys.length;
  let _key;
  while (i-- > 0) {
    _key = keys[i];
    if (key === _key.toLowerCase()) {
      return _key;
    }
  }
  return null;
}
const _global = (() => {
  if (typeof globalThis !== "undefined")
    return globalThis;
  return typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : global;
})();
const isContextDefined = (context) => !isUndefined(context) && context !== _global;
function merge() {
  const { caseless } = isContextDefined(this) && this || {};
  const result = {};
  const assignValue = (val, key) => {
    const targetKey = caseless && findKey(result, key) || key;
    if (isPlainObject(result[targetKey]) && isPlainObject(val)) {
      result[targetKey] = merge(result[targetKey], val);
    } else if (isPlainObject(val)) {
      result[targetKey] = merge({}, val);
    } else if (isArray(val)) {
      result[targetKey] = val.slice();
    } else {
      result[targetKey] = val;
    }
  };
  for (let i = 0, l = arguments.length; i < l; i++) {
    arguments[i] && forEach(arguments[i], assignValue);
  }
  return result;
}
const extend = (a, b, thisArg, { allOwnKeys } = {}) => {
  forEach(b, (val, key) => {
    if (thisArg && isFunction(val)) {
      a[key] = bind(val, thisArg);
    } else {
      a[key] = val;
    }
  }, { allOwnKeys });
  return a;
};
const stripBOM = (content) => {
  if (content.charCodeAt(0) === 65279) {
    content = content.slice(1);
  }
  return content;
};
const inherits = (constructor, superConstructor, props, descriptors2) => {
  constructor.prototype = Object.create(superConstructor.prototype, descriptors2);
  constructor.prototype.constructor = constructor;
  Object.defineProperty(constructor, "super", {
    value: superConstructor.prototype
  });
  props && Object.assign(constructor.prototype, props);
};
const toFlatObject = (sourceObj, destObj, filter2, propFilter) => {
  let props;
  let i;
  let prop;
  const merged = {};
  destObj = destObj || {};
  if (sourceObj == null)
    return destObj;
  do {
    props = Object.getOwnPropertyNames(sourceObj);
    i = props.length;
    while (i-- > 0) {
      prop = props[i];
      if ((!propFilter || propFilter(prop, sourceObj, destObj)) && !merged[prop]) {
        destObj[prop] = sourceObj[prop];
        merged[prop] = true;
      }
    }
    sourceObj = filter2 !== false && getPrototypeOf(sourceObj);
  } while (sourceObj && (!filter2 || filter2(sourceObj, destObj)) && sourceObj !== Object.prototype);
  return destObj;
};
const endsWith = (str, searchString, position) => {
  str = String(str);
  if (position === void 0 || position > str.length) {
    position = str.length;
  }
  position -= searchString.length;
  const lastIndex = str.indexOf(searchString, position);
  return lastIndex !== -1 && lastIndex === position;
};
const toArray = (thing) => {
  if (!thing)
    return null;
  if (isArray(thing))
    return thing;
  let i = thing.length;
  if (!isNumber(i))
    return null;
  const arr = new Array(i);
  while (i-- > 0) {
    arr[i] = thing[i];
  }
  return arr;
};
const isTypedArray = /* @__PURE__ */ ((TypedArray) => {
  return (thing) => {
    return TypedArray && thing instanceof TypedArray;
  };
})(typeof Uint8Array !== "undefined" && getPrototypeOf(Uint8Array));
const forEachEntry = (obj, fn) => {
  const generator = obj && obj[Symbol.iterator];
  const iterator = generator.call(obj);
  let result;
  while ((result = iterator.next()) && !result.done) {
    const pair = result.value;
    fn.call(obj, pair[0], pair[1]);
  }
};
const matchAll = (regExp, str) => {
  let matches;
  const arr = [];
  while ((matches = regExp.exec(str)) !== null) {
    arr.push(matches);
  }
  return arr;
};
const isHTMLForm = kindOfTest("HTMLFormElement");
const toCamelCase = (str) => {
  return str.toLowerCase().replace(
    /[-_\s]([a-z\d])(\w*)/g,
    function replacer(m, p1, p2) {
      return p1.toUpperCase() + p2;
    }
  );
};
const hasOwnProperty = (({ hasOwnProperty: hasOwnProperty2 }) => (obj, prop) => hasOwnProperty2.call(obj, prop))(Object.prototype);
const isRegExp = kindOfTest("RegExp");
const reduceDescriptors = (obj, reducer) => {
  const descriptors2 = Object.getOwnPropertyDescriptors(obj);
  const reducedDescriptors = {};
  forEach(descriptors2, (descriptor, name) => {
    let ret;
    if ((ret = reducer(descriptor, name, obj)) !== false) {
      reducedDescriptors[name] = ret || descriptor;
    }
  });
  Object.defineProperties(obj, reducedDescriptors);
};
const freezeMethods = (obj) => {
  reduceDescriptors(obj, (descriptor, name) => {
    if (isFunction(obj) && ["arguments", "caller", "callee"].indexOf(name) !== -1) {
      return false;
    }
    const value = obj[name];
    if (!isFunction(value))
      return;
    descriptor.enumerable = false;
    if ("writable" in descriptor) {
      descriptor.writable = false;
      return;
    }
    if (!descriptor.set) {
      descriptor.set = () => {
        throw Error("Can not rewrite read-only method '" + name + "'");
      };
    }
  });
};
const toObjectSet = (arrayOrString, delimiter) => {
  const obj = {};
  const define = (arr) => {
    arr.forEach((value) => {
      obj[value] = true;
    });
  };
  isArray(arrayOrString) ? define(arrayOrString) : define(String(arrayOrString).split(delimiter));
  return obj;
};
const noop = () => {
};
const toFiniteNumber = (value, defaultValue) => {
  value = +value;
  return Number.isFinite(value) ? value : defaultValue;
};
const ALPHA = "abcdefghijklmnopqrstuvwxyz";
const DIGIT = "0123456789";
const ALPHABET = {
  DIGIT,
  ALPHA,
  ALPHA_DIGIT: ALPHA + ALPHA.toUpperCase() + DIGIT
};
const generateString = (size = 16, alphabet = ALPHABET.ALPHA_DIGIT) => {
  let str = "";
  const { length } = alphabet;
  while (size--) {
    str += alphabet[Math.random() * length | 0];
  }
  return str;
};
function isSpecCompliantForm(thing) {
  return !!(thing && isFunction(thing.append) && thing[Symbol.toStringTag] === "FormData" && thing[Symbol.iterator]);
}
const toJSONObject = (obj) => {
  const stack = new Array(10);
  const visit = (source, i) => {
    if (isObject(source)) {
      if (stack.indexOf(source) >= 0) {
        return;
      }
      if (!("toJSON" in source)) {
        stack[i] = source;
        const target = isArray(source) ? [] : {};
        forEach(source, (value, key) => {
          const reducedValue = visit(value, i + 1);
          !isUndefined(reducedValue) && (target[key] = reducedValue);
        });
        stack[i] = void 0;
        return target;
      }
    }
    return source;
  };
  return visit(obj, 0);
};
const isAsyncFn = kindOfTest("AsyncFunction");
const isThenable = (thing) => thing && (isObject(thing) || isFunction(thing)) && isFunction(thing.then) && isFunction(thing.catch);
const utils$1 = {
  isArray,
  isArrayBuffer,
  isBuffer,
  isFormData,
  isArrayBufferView,
  isString,
  isNumber,
  isBoolean,
  isObject,
  isPlainObject,
  isUndefined,
  isDate,
  isFile,
  isBlob,
  isRegExp,
  isFunction,
  isStream,
  isURLSearchParams,
  isTypedArray,
  isFileList,
  forEach,
  merge,
  extend,
  trim,
  stripBOM,
  inherits,
  toFlatObject,
  kindOf,
  kindOfTest,
  endsWith,
  toArray,
  forEachEntry,
  matchAll,
  isHTMLForm,
  hasOwnProperty,
  hasOwnProp: hasOwnProperty,
  // an alias to avoid ESLint no-prototype-builtins detection
  reduceDescriptors,
  freezeMethods,
  toObjectSet,
  toCamelCase,
  noop,
  toFiniteNumber,
  findKey,
  global: _global,
  isContextDefined,
  ALPHABET,
  generateString,
  isSpecCompliantForm,
  toJSONObject,
  isAsyncFn,
  isThenable
};
function AxiosError(message, code, config, request, response) {
  Error.call(this);
  if (Error.captureStackTrace) {
    Error.captureStackTrace(this, this.constructor);
  } else {
    this.stack = new Error().stack;
  }
  this.message = message;
  this.name = "AxiosError";
  code && (this.code = code);
  config && (this.config = config);
  request && (this.request = request);
  response && (this.response = response);
}
utils$1.inherits(AxiosError, Error, {
  toJSON: function toJSON() {
    return {
      // Standard
      message: this.message,
      name: this.name,
      // Microsoft
      description: this.description,
      number: this.number,
      // Mozilla
      fileName: this.fileName,
      lineNumber: this.lineNumber,
      columnNumber: this.columnNumber,
      stack: this.stack,
      // Axios
      config: utils$1.toJSONObject(this.config),
      code: this.code,
      status: this.response && this.response.status ? this.response.status : null
    };
  }
});
const prototype$1 = AxiosError.prototype;
const descriptors = {};
[
  "ERR_BAD_OPTION_VALUE",
  "ERR_BAD_OPTION",
  "ECONNABORTED",
  "ETIMEDOUT",
  "ERR_NETWORK",
  "ERR_FR_TOO_MANY_REDIRECTS",
  "ERR_DEPRECATED",
  "ERR_BAD_RESPONSE",
  "ERR_BAD_REQUEST",
  "ERR_CANCELED",
  "ERR_NOT_SUPPORT",
  "ERR_INVALID_URL"
  // eslint-disable-next-line func-names
].forEach((code) => {
  descriptors[code] = { value: code };
});
Object.defineProperties(AxiosError, descriptors);
Object.defineProperty(prototype$1, "isAxiosError", { value: true });
AxiosError.from = (error, code, config, request, response, customProps) => {
  const axiosError = Object.create(prototype$1);
  utils$1.toFlatObject(error, axiosError, function filter2(obj) {
    return obj !== Error.prototype;
  }, (prop) => {
    return prop !== "isAxiosError";
  });
  AxiosError.call(axiosError, error.message, code, config, request, response);
  axiosError.cause = error;
  axiosError.name = error.name;
  customProps && Object.assign(axiosError, customProps);
  return axiosError;
};
const httpAdapter = null;
function isVisitable(thing) {
  return utils$1.isPlainObject(thing) || utils$1.isArray(thing);
}
function removeBrackets(key) {
  return utils$1.endsWith(key, "[]") ? key.slice(0, -2) : key;
}
function renderKey(path, key, dots) {
  if (!path)
    return key;
  return path.concat(key).map(function each(token, i) {
    token = removeBrackets(token);
    return !dots && i ? "[" + token + "]" : token;
  }).join(dots ? "." : "");
}
function isFlatArray(arr) {
  return utils$1.isArray(arr) && !arr.some(isVisitable);
}
const predicates = utils$1.toFlatObject(utils$1, {}, null, function filter(prop) {
  return /^is[A-Z]/.test(prop);
});
function toFormData(obj, formData, options) {
  if (!utils$1.isObject(obj)) {
    throw new TypeError("target must be an object");
  }
  formData = formData || new FormData();
  options = utils$1.toFlatObject(options, {
    metaTokens: true,
    dots: false,
    indexes: false
  }, false, function defined(option, source) {
    return !utils$1.isUndefined(source[option]);
  });
  const metaTokens = options.metaTokens;
  const visitor = options.visitor || defaultVisitor;
  const dots = options.dots;
  const indexes = options.indexes;
  const _Blob = options.Blob || typeof Blob !== "undefined" && Blob;
  const useBlob = _Blob && utils$1.isSpecCompliantForm(formData);
  if (!utils$1.isFunction(visitor)) {
    throw new TypeError("visitor must be a function");
  }
  function convertValue(value) {
    if (value === null)
      return "";
    if (utils$1.isDate(value)) {
      return value.toISOString();
    }
    if (!useBlob && utils$1.isBlob(value)) {
      throw new AxiosError("Blob is not supported. Use a Buffer instead.");
    }
    if (utils$1.isArrayBuffer(value) || utils$1.isTypedArray(value)) {
      return useBlob && typeof Blob === "function" ? new Blob([value]) : Buffer.from(value);
    }
    return value;
  }
  function defaultVisitor(value, key, path) {
    let arr = value;
    if (value && !path && typeof value === "object") {
      if (utils$1.endsWith(key, "{}")) {
        key = metaTokens ? key : key.slice(0, -2);
        value = JSON.stringify(value);
      } else if (utils$1.isArray(value) && isFlatArray(value) || (utils$1.isFileList(value) || utils$1.endsWith(key, "[]")) && (arr = utils$1.toArray(value))) {
        key = removeBrackets(key);
        arr.forEach(function each(el, index) {
          !(utils$1.isUndefined(el) || el === null) && formData.append(
            // eslint-disable-next-line no-nested-ternary
            indexes === true ? renderKey([key], index, dots) : indexes === null ? key : key + "[]",
            convertValue(el)
          );
        });
        return false;
      }
    }
    if (isVisitable(value)) {
      return true;
    }
    formData.append(renderKey(path, key, dots), convertValue(value));
    return false;
  }
  const stack = [];
  const exposedHelpers = Object.assign(predicates, {
    defaultVisitor,
    convertValue,
    isVisitable
  });
  function build(value, path) {
    if (utils$1.isUndefined(value))
      return;
    if (stack.indexOf(value) !== -1) {
      throw Error("Circular reference detected in " + path.join("."));
    }
    stack.push(value);
    utils$1.forEach(value, function each(el, key) {
      const result = !(utils$1.isUndefined(el) || el === null) && visitor.call(
        formData,
        el,
        utils$1.isString(key) ? key.trim() : key,
        path,
        exposedHelpers
      );
      if (result === true) {
        build(el, path ? path.concat(key) : [key]);
      }
    });
    stack.pop();
  }
  if (!utils$1.isObject(obj)) {
    throw new TypeError("data must be an object");
  }
  build(obj);
  return formData;
}
function encode$1(str) {
  const charMap = {
    "!": "%21",
    "'": "%27",
    "(": "%28",
    ")": "%29",
    "~": "%7E",
    "%20": "+",
    "%00": "\0"
  };
  return encodeURIComponent(str).replace(/[!'()~]|%20|%00/g, function replacer(match) {
    return charMap[match];
  });
}
function AxiosURLSearchParams(params, options) {
  this._pairs = [];
  params && toFormData(params, this, options);
}
const prototype = AxiosURLSearchParams.prototype;
prototype.append = function append(name, value) {
  this._pairs.push([name, value]);
};
prototype.toString = function toString2(encoder) {
  const _encode = encoder ? function(value) {
    return encoder.call(this, value, encode$1);
  } : encode$1;
  return this._pairs.map(function each(pair) {
    return _encode(pair[0]) + "=" + _encode(pair[1]);
  }, "").join("&");
};
function encode(val) {
  return encodeURIComponent(val).replace(/%3A/gi, ":").replace(/%24/g, "$").replace(/%2C/gi, ",").replace(/%20/g, "+").replace(/%5B/gi, "[").replace(/%5D/gi, "]");
}
function buildURL(url, params, options) {
  if (!params) {
    return url;
  }
  const _encode = options && options.encode || encode;
  const serializeFn = options && options.serialize;
  let serializedParams;
  if (serializeFn) {
    serializedParams = serializeFn(params, options);
  } else {
    serializedParams = utils$1.isURLSearchParams(params) ? params.toString() : new AxiosURLSearchParams(params, options).toString(_encode);
  }
  if (serializedParams) {
    const hashmarkIndex = url.indexOf("#");
    if (hashmarkIndex !== -1) {
      url = url.slice(0, hashmarkIndex);
    }
    url += (url.indexOf("?") === -1 ? "?" : "&") + serializedParams;
  }
  return url;
}
class InterceptorManager {
  constructor() {
    this.handlers = [];
  }
  /**
   * Add a new interceptor to the stack
   *
   * @param {Function} fulfilled The function to handle `then` for a `Promise`
   * @param {Function} rejected The function to handle `reject` for a `Promise`
   *
   * @return {Number} An ID used to remove interceptor later
   */
  use(fulfilled, rejected, options) {
    this.handlers.push({
      fulfilled,
      rejected,
      synchronous: options ? options.synchronous : false,
      runWhen: options ? options.runWhen : null
    });
    return this.handlers.length - 1;
  }
  /**
   * Remove an interceptor from the stack
   *
   * @param {Number} id The ID that was returned by `use`
   *
   * @returns {Boolean} `true` if the interceptor was removed, `false` otherwise
   */
  eject(id) {
    if (this.handlers[id]) {
      this.handlers[id] = null;
    }
  }
  /**
   * Clear all interceptors from the stack
   *
   * @returns {void}
   */
  clear() {
    if (this.handlers) {
      this.handlers = [];
    }
  }
  /**
   * Iterate over all the registered interceptors
   *
   * This method is particularly useful for skipping over any
   * interceptors that may have become `null` calling `eject`.
   *
   * @param {Function} fn The function to call for each interceptor
   *
   * @returns {void}
   */
  forEach(fn) {
    utils$1.forEach(this.handlers, function forEachHandler(h) {
      if (h !== null) {
        fn(h);
      }
    });
  }
}
const transitionalDefaults = {
  silentJSONParsing: true,
  forcedJSONParsing: true,
  clarifyTimeoutError: false
};
const URLSearchParams$1 = typeof URLSearchParams !== "undefined" ? URLSearchParams : AxiosURLSearchParams;
const FormData$1 = typeof FormData !== "undefined" ? FormData : null;
const Blob$1 = typeof Blob !== "undefined" ? Blob : null;
const platform$1 = {
  isBrowser: true,
  classes: {
    URLSearchParams: URLSearchParams$1,
    FormData: FormData$1,
    Blob: Blob$1
  },
  protocols: ["http", "https", "file", "blob", "url", "data"]
};
const hasBrowserEnv = typeof window !== "undefined" && typeof document !== "undefined";
const hasStandardBrowserEnv = ((product) => {
  return hasBrowserEnv && ["ReactNative", "NativeScript", "NS"].indexOf(product) < 0;
})(typeof navigator !== "undefined" && navigator.product);
const hasStandardBrowserWebWorkerEnv = (() => {
  return typeof WorkerGlobalScope !== "undefined" && // eslint-disable-next-line no-undef
  self instanceof WorkerGlobalScope && typeof self.importScripts === "function";
})();
const utils = /* @__PURE__ */ Object.freeze(/* @__PURE__ */ Object.defineProperty({
  __proto__: null,
  hasBrowserEnv,
  hasStandardBrowserEnv,
  hasStandardBrowserWebWorkerEnv
}, Symbol.toStringTag, { value: "Module" }));
const platform = {
  ...utils,
  ...platform$1
};
function toURLEncodedForm(data, options) {
  return toFormData(data, new platform.classes.URLSearchParams(), Object.assign({
    visitor: function(value, key, path, helpers) {
      if (platform.isNode && utils$1.isBuffer(value)) {
        this.append(key, value.toString("base64"));
        return false;
      }
      return helpers.defaultVisitor.apply(this, arguments);
    }
  }, options));
}
function parsePropPath(name) {
  return utils$1.matchAll(/\w+|\[(\w*)]/g, name).map((match) => {
    return match[0] === "[]" ? "" : match[1] || match[0];
  });
}
function arrayToObject(arr) {
  const obj = {};
  const keys = Object.keys(arr);
  let i;
  const len = keys.length;
  let key;
  for (i = 0; i < len; i++) {
    key = keys[i];
    obj[key] = arr[key];
  }
  return obj;
}
function formDataToJSON(formData) {
  function buildPath(path, value, target, index) {
    let name = path[index++];
    if (name === "__proto__")
      return true;
    const isNumericKey = Number.isFinite(+name);
    const isLast = index >= path.length;
    name = !name && utils$1.isArray(target) ? target.length : name;
    if (isLast) {
      if (utils$1.hasOwnProp(target, name)) {
        target[name] = [target[name], value];
      } else {
        target[name] = value;
      }
      return !isNumericKey;
    }
    if (!target[name] || !utils$1.isObject(target[name])) {
      target[name] = [];
    }
    const result = buildPath(path, value, target[name], index);
    if (result && utils$1.isArray(target[name])) {
      target[name] = arrayToObject(target[name]);
    }
    return !isNumericKey;
  }
  if (utils$1.isFormData(formData) && utils$1.isFunction(formData.entries)) {
    const obj = {};
    utils$1.forEachEntry(formData, (name, value) => {
      buildPath(parsePropPath(name), value, obj, 0);
    });
    return obj;
  }
  return null;
}
function stringifySafely(rawValue, parser, encoder) {
  if (utils$1.isString(rawValue)) {
    try {
      (parser || JSON.parse)(rawValue);
      return utils$1.trim(rawValue);
    } catch (e) {
      if (e.name !== "SyntaxError") {
        throw e;
      }
    }
  }
  return (encoder || JSON.stringify)(rawValue);
}
const defaults = {
  transitional: transitionalDefaults,
  adapter: ["xhr", "http"],
  transformRequest: [function transformRequest(data, headers) {
    const contentType = headers.getContentType() || "";
    const hasJSONContentType = contentType.indexOf("application/json") > -1;
    const isObjectPayload = utils$1.isObject(data);
    if (isObjectPayload && utils$1.isHTMLForm(data)) {
      data = new FormData(data);
    }
    const isFormData2 = utils$1.isFormData(data);
    if (isFormData2) {
      if (!hasJSONContentType) {
        return data;
      }
      return hasJSONContentType ? JSON.stringify(formDataToJSON(data)) : data;
    }
    if (utils$1.isArrayBuffer(data) || utils$1.isBuffer(data) || utils$1.isStream(data) || utils$1.isFile(data) || utils$1.isBlob(data)) {
      return data;
    }
    if (utils$1.isArrayBufferView(data)) {
      return data.buffer;
    }
    if (utils$1.isURLSearchParams(data)) {
      headers.setContentType("application/x-www-form-urlencoded;charset=utf-8", false);
      return data.toString();
    }
    let isFileList2;
    if (isObjectPayload) {
      if (contentType.indexOf("application/x-www-form-urlencoded") > -1) {
        return toURLEncodedForm(data, this.formSerializer).toString();
      }
      if ((isFileList2 = utils$1.isFileList(data)) || contentType.indexOf("multipart/form-data") > -1) {
        const _FormData = this.env && this.env.FormData;
        return toFormData(
          isFileList2 ? { "files[]": data } : data,
          _FormData && new _FormData(),
          this.formSerializer
        );
      }
    }
    if (isObjectPayload || hasJSONContentType) {
      headers.setContentType("application/json", false);
      return stringifySafely(data);
    }
    return data;
  }],
  transformResponse: [function transformResponse(data) {
    const transitional2 = this.transitional || defaults.transitional;
    const forcedJSONParsing = transitional2 && transitional2.forcedJSONParsing;
    const JSONRequested = this.responseType === "json";
    if (data && utils$1.isString(data) && (forcedJSONParsing && !this.responseType || JSONRequested)) {
      const silentJSONParsing = transitional2 && transitional2.silentJSONParsing;
      const strictJSONParsing = !silentJSONParsing && JSONRequested;
      try {
        return JSON.parse(data);
      } catch (e) {
        if (strictJSONParsing) {
          if (e.name === "SyntaxError") {
            throw AxiosError.from(e, AxiosError.ERR_BAD_RESPONSE, this, null, this.response);
          }
          throw e;
        }
      }
    }
    return data;
  }],
  /**
   * A timeout in milliseconds to abort a request. If set to 0 (default) a
   * timeout is not created.
   */
  timeout: 0,
  xsrfCookieName: "XSRF-TOKEN",
  xsrfHeaderName: "X-XSRF-TOKEN",
  maxContentLength: -1,
  maxBodyLength: -1,
  env: {
    FormData: platform.classes.FormData,
    Blob: platform.classes.Blob
  },
  validateStatus: function validateStatus(status) {
    return status >= 200 && status < 300;
  },
  headers: {
    common: {
      "Accept": "application/json, text/plain, */*",
      "Content-Type": void 0
    }
  }
};
utils$1.forEach(["delete", "get", "head", "post", "put", "patch"], (method) => {
  defaults.headers[method] = {};
});
const defaults$1 = defaults;
const ignoreDuplicateOf = utils$1.toObjectSet([
  "age",
  "authorization",
  "content-length",
  "content-type",
  "etag",
  "expires",
  "from",
  "host",
  "if-modified-since",
  "if-unmodified-since",
  "last-modified",
  "location",
  "max-forwards",
  "proxy-authorization",
  "referer",
  "retry-after",
  "user-agent"
]);
const parseHeaders = (rawHeaders) => {
  const parsed = {};
  let key;
  let val;
  let i;
  rawHeaders && rawHeaders.split("\n").forEach(function parser(line) {
    i = line.indexOf(":");
    key = line.substring(0, i).trim().toLowerCase();
    val = line.substring(i + 1).trim();
    if (!key || parsed[key] && ignoreDuplicateOf[key]) {
      return;
    }
    if (key === "set-cookie") {
      if (parsed[key]) {
        parsed[key].push(val);
      } else {
        parsed[key] = [val];
      }
    } else {
      parsed[key] = parsed[key] ? parsed[key] + ", " + val : val;
    }
  });
  return parsed;
};
const $internals = Symbol("internals");
function normalizeHeader(header) {
  return header && String(header).trim().toLowerCase();
}
function normalizeValue(value) {
  if (value === false || value == null) {
    return value;
  }
  return utils$1.isArray(value) ? value.map(normalizeValue) : String(value);
}
function parseTokens(str) {
  const tokens = /* @__PURE__ */ Object.create(null);
  const tokensRE = /([^\s,;=]+)\s*(?:=\s*([^,;]+))?/g;
  let match;
  while (match = tokensRE.exec(str)) {
    tokens[match[1]] = match[2];
  }
  return tokens;
}
const isValidHeaderName = (str) => /^[-_a-zA-Z0-9^`|~,!#$%&'*+.]+$/.test(str.trim());
function matchHeaderValue(context, value, header, filter2, isHeaderNameFilter) {
  if (utils$1.isFunction(filter2)) {
    return filter2.call(this, value, header);
  }
  if (isHeaderNameFilter) {
    value = header;
  }
  if (!utils$1.isString(value))
    return;
  if (utils$1.isString(filter2)) {
    return value.indexOf(filter2) !== -1;
  }
  if (utils$1.isRegExp(filter2)) {
    return filter2.test(value);
  }
}
function formatHeader(header) {
  return header.trim().toLowerCase().replace(/([a-z\d])(\w*)/g, (w, char, str) => {
    return char.toUpperCase() + str;
  });
}
function buildAccessors(obj, header) {
  const accessorName = utils$1.toCamelCase(" " + header);
  ["get", "set", "has"].forEach((methodName) => {
    Object.defineProperty(obj, methodName + accessorName, {
      value: function(arg1, arg2, arg3) {
        return this[methodName].call(this, header, arg1, arg2, arg3);
      },
      configurable: true
    });
  });
}
class AxiosHeaders {
  constructor(headers) {
    headers && this.set(headers);
  }
  set(header, valueOrRewrite, rewrite) {
    const self2 = this;
    function setHeader(_value, _header, _rewrite) {
      const lHeader = normalizeHeader(_header);
      if (!lHeader) {
        throw new Error("header name must be a non-empty string");
      }
      const key = utils$1.findKey(self2, lHeader);
      if (!key || self2[key] === void 0 || _rewrite === true || _rewrite === void 0 && self2[key] !== false) {
        self2[key || _header] = normalizeValue(_value);
      }
    }
    const setHeaders = (headers, _rewrite) => utils$1.forEach(headers, (_value, _header) => setHeader(_value, _header, _rewrite));
    if (utils$1.isPlainObject(header) || header instanceof this.constructor) {
      setHeaders(header, valueOrRewrite);
    } else if (utils$1.isString(header) && (header = header.trim()) && !isValidHeaderName(header)) {
      setHeaders(parseHeaders(header), valueOrRewrite);
    } else {
      header != null && setHeader(valueOrRewrite, header, rewrite);
    }
    return this;
  }
  get(header, parser) {
    header = normalizeHeader(header);
    if (header) {
      const key = utils$1.findKey(this, header);
      if (key) {
        const value = this[key];
        if (!parser) {
          return value;
        }
        if (parser === true) {
          return parseTokens(value);
        }
        if (utils$1.isFunction(parser)) {
          return parser.call(this, value, key);
        }
        if (utils$1.isRegExp(parser)) {
          return parser.exec(value);
        }
        throw new TypeError("parser must be boolean|regexp|function");
      }
    }
  }
  has(header, matcher) {
    header = normalizeHeader(header);
    if (header) {
      const key = utils$1.findKey(this, header);
      return !!(key && this[key] !== void 0 && (!matcher || matchHeaderValue(this, this[key], key, matcher)));
    }
    return false;
  }
  delete(header, matcher) {
    const self2 = this;
    let deleted = false;
    function deleteHeader(_header) {
      _header = normalizeHeader(_header);
      if (_header) {
        const key = utils$1.findKey(self2, _header);
        if (key && (!matcher || matchHeaderValue(self2, self2[key], key, matcher))) {
          delete self2[key];
          deleted = true;
        }
      }
    }
    if (utils$1.isArray(header)) {
      header.forEach(deleteHeader);
    } else {
      deleteHeader(header);
    }
    return deleted;
  }
  clear(matcher) {
    const keys = Object.keys(this);
    let i = keys.length;
    let deleted = false;
    while (i--) {
      const key = keys[i];
      if (!matcher || matchHeaderValue(this, this[key], key, matcher, true)) {
        delete this[key];
        deleted = true;
      }
    }
    return deleted;
  }
  normalize(format) {
    const self2 = this;
    const headers = {};
    utils$1.forEach(this, (value, header) => {
      const key = utils$1.findKey(headers, header);
      if (key) {
        self2[key] = normalizeValue(value);
        delete self2[header];
        return;
      }
      const normalized = format ? formatHeader(header) : String(header).trim();
      if (normalized !== header) {
        delete self2[header];
      }
      self2[normalized] = normalizeValue(value);
      headers[normalized] = true;
    });
    return this;
  }
  concat(...targets) {
    return this.constructor.concat(this, ...targets);
  }
  toJSON(asStrings) {
    const obj = /* @__PURE__ */ Object.create(null);
    utils$1.forEach(this, (value, header) => {
      value != null && value !== false && (obj[header] = asStrings && utils$1.isArray(value) ? value.join(", ") : value);
    });
    return obj;
  }
  [Symbol.iterator]() {
    return Object.entries(this.toJSON())[Symbol.iterator]();
  }
  toString() {
    return Object.entries(this.toJSON()).map(([header, value]) => header + ": " + value).join("\n");
  }
  get [Symbol.toStringTag]() {
    return "AxiosHeaders";
  }
  static from(thing) {
    return thing instanceof this ? thing : new this(thing);
  }
  static concat(first, ...targets) {
    const computed = new this(first);
    targets.forEach((target) => computed.set(target));
    return computed;
  }
  static accessor(header) {
    const internals = this[$internals] = this[$internals] = {
      accessors: {}
    };
    const accessors = internals.accessors;
    const prototype2 = this.prototype;
    function defineAccessor(_header) {
      const lHeader = normalizeHeader(_header);
      if (!accessors[lHeader]) {
        buildAccessors(prototype2, _header);
        accessors[lHeader] = true;
      }
    }
    utils$1.isArray(header) ? header.forEach(defineAccessor) : defineAccessor(header);
    return this;
  }
}
AxiosHeaders.accessor(["Content-Type", "Content-Length", "Accept", "Accept-Encoding", "User-Agent", "Authorization"]);
utils$1.reduceDescriptors(AxiosHeaders.prototype, ({ value }, key) => {
  let mapped = key[0].toUpperCase() + key.slice(1);
  return {
    get: () => value,
    set(headerValue) {
      this[mapped] = headerValue;
    }
  };
});
utils$1.freezeMethods(AxiosHeaders);
const AxiosHeaders$1 = AxiosHeaders;
function transformData(fns, response) {
  const config = this || defaults$1;
  const context = response || config;
  const headers = AxiosHeaders$1.from(context.headers);
  let data = context.data;
  utils$1.forEach(fns, function transform(fn) {
    data = fn.call(config, data, headers.normalize(), response ? response.status : void 0);
  });
  headers.normalize();
  return data;
}
function isCancel(value) {
  return !!(value && value.__CANCEL__);
}
function CanceledError(message, config, request) {
  AxiosError.call(this, message == null ? "canceled" : message, AxiosError.ERR_CANCELED, config, request);
  this.name = "CanceledError";
}
utils$1.inherits(CanceledError, AxiosError, {
  __CANCEL__: true
});
function settle(resolve, reject, response) {
  const validateStatus2 = response.config.validateStatus;
  if (!response.status || !validateStatus2 || validateStatus2(response.status)) {
    resolve(response);
  } else {
    reject(new AxiosError(
      "Request failed with status code " + response.status,
      [AxiosError.ERR_BAD_REQUEST, AxiosError.ERR_BAD_RESPONSE][Math.floor(response.status / 100) - 4],
      response.config,
      response.request,
      response
    ));
  }
}
const cookies = platform.hasStandardBrowserEnv ? (
  // Standard browser envs support document.cookie
  {
    write(name, value, expires, path, domain, secure) {
      const cookie = [name + "=" + encodeURIComponent(value)];
      utils$1.isNumber(expires) && cookie.push("expires=" + new Date(expires).toGMTString());
      utils$1.isString(path) && cookie.push("path=" + path);
      utils$1.isString(domain) && cookie.push("domain=" + domain);
      secure === true && cookie.push("secure");
      document.cookie = cookie.join("; ");
    },
    read(name) {
      const match = document.cookie.match(new RegExp("(^|;\\s*)(" + name + ")=([^;]*)"));
      return match ? decodeURIComponent(match[3]) : null;
    },
    remove(name) {
      this.write(name, "", Date.now() - 864e5);
    }
  }
) : (
  // Non-standard browser env (web workers, react-native) lack needed support.
  {
    write() {
    },
    read() {
      return null;
    },
    remove() {
    }
  }
);
function isAbsoluteURL(url) {
  return /^([a-z][a-z\d+\-.]*:)?\/\//i.test(url);
}
function combineURLs(baseURL, relativeURL) {
  return relativeURL ? baseURL.replace(/\/?\/$/, "") + "/" + relativeURL.replace(/^\/+/, "") : baseURL;
}
function buildFullPath(baseURL, requestedURL) {
  if (baseURL && !isAbsoluteURL(requestedURL)) {
    return combineURLs(baseURL, requestedURL);
  }
  return requestedURL;
}
const isURLSameOrigin = platform.hasStandardBrowserEnv ? (
  // Standard browser envs have full support of the APIs needed to test
  // whether the request URL is of the same origin as current location.
  function standardBrowserEnv() {
    const msie = /(msie|trident)/i.test(navigator.userAgent);
    const urlParsingNode = document.createElement("a");
    let originURL;
    function resolveURL(url) {
      let href = url;
      if (msie) {
        urlParsingNode.setAttribute("href", href);
        href = urlParsingNode.href;
      }
      urlParsingNode.setAttribute("href", href);
      return {
        href: urlParsingNode.href,
        protocol: urlParsingNode.protocol ? urlParsingNode.protocol.replace(/:$/, "") : "",
        host: urlParsingNode.host,
        search: urlParsingNode.search ? urlParsingNode.search.replace(/^\?/, "") : "",
        hash: urlParsingNode.hash ? urlParsingNode.hash.replace(/^#/, "") : "",
        hostname: urlParsingNode.hostname,
        port: urlParsingNode.port,
        pathname: urlParsingNode.pathname.charAt(0) === "/" ? urlParsingNode.pathname : "/" + urlParsingNode.pathname
      };
    }
    originURL = resolveURL(window.location.href);
    return function isURLSameOrigin2(requestURL) {
      const parsed = utils$1.isString(requestURL) ? resolveURL(requestURL) : requestURL;
      return parsed.protocol === originURL.protocol && parsed.host === originURL.host;
    };
  }()
) : (
  // Non standard browser envs (web workers, react-native) lack needed support.
  /* @__PURE__ */ function nonStandardBrowserEnv() {
    return function isURLSameOrigin2() {
      return true;
    };
  }()
);
function parseProtocol(url) {
  const match = /^([-+\w]{1,25})(:?\/\/|:)/.exec(url);
  return match && match[1] || "";
}
function speedometer(samplesCount, min) {
  samplesCount = samplesCount || 10;
  const bytes = new Array(samplesCount);
  const timestamps = new Array(samplesCount);
  let head = 0;
  let tail = 0;
  let firstSampleTS;
  min = min !== void 0 ? min : 1e3;
  return function push(chunkLength) {
    const now = Date.now();
    const startedAt = timestamps[tail];
    if (!firstSampleTS) {
      firstSampleTS = now;
    }
    bytes[head] = chunkLength;
    timestamps[head] = now;
    let i = tail;
    let bytesCount = 0;
    while (i !== head) {
      bytesCount += bytes[i++];
      i = i % samplesCount;
    }
    head = (head + 1) % samplesCount;
    if (head === tail) {
      tail = (tail + 1) % samplesCount;
    }
    if (now - firstSampleTS < min) {
      return;
    }
    const passed = startedAt && now - startedAt;
    return passed ? Math.round(bytesCount * 1e3 / passed) : void 0;
  };
}
function progressEventReducer(listener, isDownloadStream) {
  let bytesNotified = 0;
  const _speedometer = speedometer(50, 250);
  return (e) => {
    const loaded = e.loaded;
    const total = e.lengthComputable ? e.total : void 0;
    const progressBytes = loaded - bytesNotified;
    const rate = _speedometer(progressBytes);
    const inRange = loaded <= total;
    bytesNotified = loaded;
    const data = {
      loaded,
      total,
      progress: total ? loaded / total : void 0,
      bytes: progressBytes,
      rate: rate ? rate : void 0,
      estimated: rate && total && inRange ? (total - loaded) / rate : void 0,
      event: e
    };
    data[isDownloadStream ? "download" : "upload"] = true;
    listener(data);
  };
}
const isXHRAdapterSupported = typeof XMLHttpRequest !== "undefined";
const xhrAdapter = isXHRAdapterSupported && function(config) {
  return new Promise(function dispatchXhrRequest(resolve, reject) {
    let requestData = config.data;
    const requestHeaders = AxiosHeaders$1.from(config.headers).normalize();
    let { responseType, withXSRFToken } = config;
    let onCanceled;
    function done() {
      if (config.cancelToken) {
        config.cancelToken.unsubscribe(onCanceled);
      }
      if (config.signal) {
        config.signal.removeEventListener("abort", onCanceled);
      }
    }
    let contentType;
    if (utils$1.isFormData(requestData)) {
      if (platform.hasStandardBrowserEnv || platform.hasStandardBrowserWebWorkerEnv) {
        requestHeaders.setContentType(false);
      } else if ((contentType = requestHeaders.getContentType()) !== false) {
        const [type, ...tokens] = contentType ? contentType.split(";").map((token) => token.trim()).filter(Boolean) : [];
        requestHeaders.setContentType([type || "multipart/form-data", ...tokens].join("; "));
      }
    }
    let request = new XMLHttpRequest();
    if (config.auth) {
      const username = config.auth.username || "";
      const password = config.auth.password ? unescape(encodeURIComponent(config.auth.password)) : "";
      requestHeaders.set("Authorization", "Basic " + btoa(username + ":" + password));
    }
    const fullPath = buildFullPath(config.baseURL, config.url);
    request.open(config.method.toUpperCase(), buildURL(fullPath, config.params, config.paramsSerializer), true);
    request.timeout = config.timeout;
    function onloadend() {
      if (!request) {
        return;
      }
      const responseHeaders = AxiosHeaders$1.from(
        "getAllResponseHeaders" in request && request.getAllResponseHeaders()
      );
      const responseData = !responseType || responseType === "text" || responseType === "json" ? request.responseText : request.response;
      const response = {
        data: responseData,
        status: request.status,
        statusText: request.statusText,
        headers: responseHeaders,
        config,
        request
      };
      settle(function _resolve(value) {
        resolve(value);
        done();
      }, function _reject(err) {
        reject(err);
        done();
      }, response);
      request = null;
    }
    if ("onloadend" in request) {
      request.onloadend = onloadend;
    } else {
      request.onreadystatechange = function handleLoad() {
        if (!request || request.readyState !== 4) {
          return;
        }
        if (request.status === 0 && !(request.responseURL && request.responseURL.indexOf("file:") === 0)) {
          return;
        }
        setTimeout(onloadend);
      };
    }
    request.onabort = function handleAbort() {
      if (!request) {
        return;
      }
      reject(new AxiosError("Request aborted", AxiosError.ECONNABORTED, config, request));
      request = null;
    };
    request.onerror = function handleError() {
      reject(new AxiosError("Network Error", AxiosError.ERR_NETWORK, config, request));
      request = null;
    };
    request.ontimeout = function handleTimeout() {
      let timeoutErrorMessage = config.timeout ? "timeout of " + config.timeout + "ms exceeded" : "timeout exceeded";
      const transitional2 = config.transitional || transitionalDefaults;
      if (config.timeoutErrorMessage) {
        timeoutErrorMessage = config.timeoutErrorMessage;
      }
      reject(new AxiosError(
        timeoutErrorMessage,
        transitional2.clarifyTimeoutError ? AxiosError.ETIMEDOUT : AxiosError.ECONNABORTED,
        config,
        request
      ));
      request = null;
    };
    if (platform.hasStandardBrowserEnv) {
      withXSRFToken && utils$1.isFunction(withXSRFToken) && (withXSRFToken = withXSRFToken(config));
      if (withXSRFToken || withXSRFToken !== false && isURLSameOrigin(fullPath)) {
        const xsrfValue = config.xsrfHeaderName && config.xsrfCookieName && cookies.read(config.xsrfCookieName);
        if (xsrfValue) {
          requestHeaders.set(config.xsrfHeaderName, xsrfValue);
        }
      }
    }
    requestData === void 0 && requestHeaders.setContentType(null);
    if ("setRequestHeader" in request) {
      utils$1.forEach(requestHeaders.toJSON(), function setRequestHeader(val, key) {
        request.setRequestHeader(key, val);
      });
    }
    if (!utils$1.isUndefined(config.withCredentials)) {
      request.withCredentials = !!config.withCredentials;
    }
    if (responseType && responseType !== "json") {
      request.responseType = config.responseType;
    }
    if (typeof config.onDownloadProgress === "function") {
      request.addEventListener("progress", progressEventReducer(config.onDownloadProgress, true));
    }
    if (typeof config.onUploadProgress === "function" && request.upload) {
      request.upload.addEventListener("progress", progressEventReducer(config.onUploadProgress));
    }
    if (config.cancelToken || config.signal) {
      onCanceled = (cancel) => {
        if (!request) {
          return;
        }
        reject(!cancel || cancel.type ? new CanceledError(null, config, request) : cancel);
        request.abort();
        request = null;
      };
      config.cancelToken && config.cancelToken.subscribe(onCanceled);
      if (config.signal) {
        config.signal.aborted ? onCanceled() : config.signal.addEventListener("abort", onCanceled);
      }
    }
    const protocol = parseProtocol(fullPath);
    if (protocol && platform.protocols.indexOf(protocol) === -1) {
      reject(new AxiosError("Unsupported protocol " + protocol + ":", AxiosError.ERR_BAD_REQUEST, config));
      return;
    }
    request.send(requestData || null);
  });
};
const knownAdapters = {
  http: httpAdapter,
  xhr: xhrAdapter
};
utils$1.forEach(knownAdapters, (fn, value) => {
  if (fn) {
    try {
      Object.defineProperty(fn, "name", { value });
    } catch (e) {
    }
    Object.defineProperty(fn, "adapterName", { value });
  }
});
const renderReason = (reason) => `- ${reason}`;
const isResolvedHandle = (adapter) => utils$1.isFunction(adapter) || adapter === null || adapter === false;
const adapters = {
  getAdapter: (adapters2) => {
    adapters2 = utils$1.isArray(adapters2) ? adapters2 : [adapters2];
    const { length } = adapters2;
    let nameOrAdapter;
    let adapter;
    const rejectedReasons = {};
    for (let i = 0; i < length; i++) {
      nameOrAdapter = adapters2[i];
      let id;
      adapter = nameOrAdapter;
      if (!isResolvedHandle(nameOrAdapter)) {
        adapter = knownAdapters[(id = String(nameOrAdapter)).toLowerCase()];
        if (adapter === void 0) {
          throw new AxiosError(`Unknown adapter '${id}'`);
        }
      }
      if (adapter) {
        break;
      }
      rejectedReasons[id || "#" + i] = adapter;
    }
    if (!adapter) {
      const reasons = Object.entries(rejectedReasons).map(
        ([id, state]) => `adapter ${id} ` + (state === false ? "is not supported by the environment" : "is not available in the build")
      );
      let s = length ? reasons.length > 1 ? "since :\n" + reasons.map(renderReason).join("\n") : " " + renderReason(reasons[0]) : "as no adapter specified";
      throw new AxiosError(
        `There is no suitable adapter to dispatch the request ` + s,
        "ERR_NOT_SUPPORT"
      );
    }
    return adapter;
  },
  adapters: knownAdapters
};
function throwIfCancellationRequested(config) {
  if (config.cancelToken) {
    config.cancelToken.throwIfRequested();
  }
  if (config.signal && config.signal.aborted) {
    throw new CanceledError(null, config);
  }
}
function dispatchRequest(config) {
  throwIfCancellationRequested(config);
  config.headers = AxiosHeaders$1.from(config.headers);
  config.data = transformData.call(
    config,
    config.transformRequest
  );
  if (["post", "put", "patch"].indexOf(config.method) !== -1) {
    config.headers.setContentType("application/x-www-form-urlencoded", false);
  }
  const adapter = adapters.getAdapter(config.adapter || defaults$1.adapter);
  return adapter(config).then(function onAdapterResolution(response) {
    throwIfCancellationRequested(config);
    response.data = transformData.call(
      config,
      config.transformResponse,
      response
    );
    response.headers = AxiosHeaders$1.from(response.headers);
    return response;
  }, function onAdapterRejection(reason) {
    if (!isCancel(reason)) {
      throwIfCancellationRequested(config);
      if (reason && reason.response) {
        reason.response.data = transformData.call(
          config,
          config.transformResponse,
          reason.response
        );
        reason.response.headers = AxiosHeaders$1.from(reason.response.headers);
      }
    }
    return Promise.reject(reason);
  });
}
const headersToObject = (thing) => thing instanceof AxiosHeaders$1 ? thing.toJSON() : thing;
function mergeConfig(config1, config2) {
  config2 = config2 || {};
  const config = {};
  function getMergedValue(target, source, caseless) {
    if (utils$1.isPlainObject(target) && utils$1.isPlainObject(source)) {
      return utils$1.merge.call({ caseless }, target, source);
    } else if (utils$1.isPlainObject(source)) {
      return utils$1.merge({}, source);
    } else if (utils$1.isArray(source)) {
      return source.slice();
    }
    return source;
  }
  function mergeDeepProperties(a, b, caseless) {
    if (!utils$1.isUndefined(b)) {
      return getMergedValue(a, b, caseless);
    } else if (!utils$1.isUndefined(a)) {
      return getMergedValue(void 0, a, caseless);
    }
  }
  function valueFromConfig2(a, b) {
    if (!utils$1.isUndefined(b)) {
      return getMergedValue(void 0, b);
    }
  }
  function defaultToConfig2(a, b) {
    if (!utils$1.isUndefined(b)) {
      return getMergedValue(void 0, b);
    } else if (!utils$1.isUndefined(a)) {
      return getMergedValue(void 0, a);
    }
  }
  function mergeDirectKeys(a, b, prop) {
    if (prop in config2) {
      return getMergedValue(a, b);
    } else if (prop in config1) {
      return getMergedValue(void 0, a);
    }
  }
  const mergeMap = {
    url: valueFromConfig2,
    method: valueFromConfig2,
    data: valueFromConfig2,
    baseURL: defaultToConfig2,
    transformRequest: defaultToConfig2,
    transformResponse: defaultToConfig2,
    paramsSerializer: defaultToConfig2,
    timeout: defaultToConfig2,
    timeoutMessage: defaultToConfig2,
    withCredentials: defaultToConfig2,
    withXSRFToken: defaultToConfig2,
    adapter: defaultToConfig2,
    responseType: defaultToConfig2,
    xsrfCookieName: defaultToConfig2,
    xsrfHeaderName: defaultToConfig2,
    onUploadProgress: defaultToConfig2,
    onDownloadProgress: defaultToConfig2,
    decompress: defaultToConfig2,
    maxContentLength: defaultToConfig2,
    maxBodyLength: defaultToConfig2,
    beforeRedirect: defaultToConfig2,
    transport: defaultToConfig2,
    httpAgent: defaultToConfig2,
    httpsAgent: defaultToConfig2,
    cancelToken: defaultToConfig2,
    socketPath: defaultToConfig2,
    responseEncoding: defaultToConfig2,
    validateStatus: mergeDirectKeys,
    headers: (a, b) => mergeDeepProperties(headersToObject(a), headersToObject(b), true)
  };
  utils$1.forEach(Object.keys(Object.assign({}, config1, config2)), function computeConfigValue(prop) {
    const merge2 = mergeMap[prop] || mergeDeepProperties;
    const configValue = merge2(config1[prop], config2[prop], prop);
    utils$1.isUndefined(configValue) && merge2 !== mergeDirectKeys || (config[prop] = configValue);
  });
  return config;
}
const VERSION = "1.6.5";
const validators$1 = {};
["object", "boolean", "number", "function", "string", "symbol"].forEach((type, i) => {
  validators$1[type] = function validator2(thing) {
    return typeof thing === type || "a" + (i < 1 ? "n " : " ") + type;
  };
});
const deprecatedWarnings = {};
validators$1.transitional = function transitional(validator2, version, message) {
  function formatMessage(opt, desc) {
    return "[Axios v" + VERSION + "] Transitional option '" + opt + "'" + desc + (message ? ". " + message : "");
  }
  return (value, opt, opts) => {
    if (validator2 === false) {
      throw new AxiosError(
        formatMessage(opt, " has been removed" + (version ? " in " + version : "")),
        AxiosError.ERR_DEPRECATED
      );
    }
    if (version && !deprecatedWarnings[opt]) {
      deprecatedWarnings[opt] = true;
      console.warn(
        formatMessage(
          opt,
          " has been deprecated since v" + version + " and will be removed in the near future"
        )
      );
    }
    return validator2 ? validator2(value, opt, opts) : true;
  };
};
function assertOptions(options, schema, allowUnknown) {
  if (typeof options !== "object") {
    throw new AxiosError("options must be an object", AxiosError.ERR_BAD_OPTION_VALUE);
  }
  const keys = Object.keys(options);
  let i = keys.length;
  while (i-- > 0) {
    const opt = keys[i];
    const validator2 = schema[opt];
    if (validator2) {
      const value = options[opt];
      const result = value === void 0 || validator2(value, opt, options);
      if (result !== true) {
        throw new AxiosError("option " + opt + " must be " + result, AxiosError.ERR_BAD_OPTION_VALUE);
      }
      continue;
    }
    if (allowUnknown !== true) {
      throw new AxiosError("Unknown option " + opt, AxiosError.ERR_BAD_OPTION);
    }
  }
}
const validator = {
  assertOptions,
  validators: validators$1
};
const validators = validator.validators;
class Axios {
  constructor(instanceConfig) {
    this.defaults = instanceConfig;
    this.interceptors = {
      request: new InterceptorManager(),
      response: new InterceptorManager()
    };
  }
  /**
   * Dispatch a request
   *
   * @param {String|Object} configOrUrl The config specific for this request (merged with this.defaults)
   * @param {?Object} config
   *
   * @returns {Promise} The Promise to be fulfilled
   */
  request(configOrUrl, config) {
    if (typeof configOrUrl === "string") {
      config = config || {};
      config.url = configOrUrl;
    } else {
      config = configOrUrl || {};
    }
    config = mergeConfig(this.defaults, config);
    const { transitional: transitional2, paramsSerializer, headers } = config;
    if (transitional2 !== void 0) {
      validator.assertOptions(transitional2, {
        silentJSONParsing: validators.transitional(validators.boolean),
        forcedJSONParsing: validators.transitional(validators.boolean),
        clarifyTimeoutError: validators.transitional(validators.boolean)
      }, false);
    }
    if (paramsSerializer != null) {
      if (utils$1.isFunction(paramsSerializer)) {
        config.paramsSerializer = {
          serialize: paramsSerializer
        };
      } else {
        validator.assertOptions(paramsSerializer, {
          encode: validators.function,
          serialize: validators.function
        }, true);
      }
    }
    config.method = (config.method || this.defaults.method || "get").toLowerCase();
    let contextHeaders = headers && utils$1.merge(
      headers.common,
      headers[config.method]
    );
    headers && utils$1.forEach(
      ["delete", "get", "head", "post", "put", "patch", "common"],
      (method) => {
        delete headers[method];
      }
    );
    config.headers = AxiosHeaders$1.concat(contextHeaders, headers);
    const requestInterceptorChain = [];
    let synchronousRequestInterceptors = true;
    this.interceptors.request.forEach(function unshiftRequestInterceptors(interceptor) {
      if (typeof interceptor.runWhen === "function" && interceptor.runWhen(config) === false) {
        return;
      }
      synchronousRequestInterceptors = synchronousRequestInterceptors && interceptor.synchronous;
      requestInterceptorChain.unshift(interceptor.fulfilled, interceptor.rejected);
    });
    const responseInterceptorChain = [];
    this.interceptors.response.forEach(function pushResponseInterceptors(interceptor) {
      responseInterceptorChain.push(interceptor.fulfilled, interceptor.rejected);
    });
    let promise;
    let i = 0;
    let len;
    if (!synchronousRequestInterceptors) {
      const chain = [dispatchRequest.bind(this), void 0];
      chain.unshift.apply(chain, requestInterceptorChain);
      chain.push.apply(chain, responseInterceptorChain);
      len = chain.length;
      promise = Promise.resolve(config);
      while (i < len) {
        promise = promise.then(chain[i++], chain[i++]);
      }
      return promise;
    }
    len = requestInterceptorChain.length;
    let newConfig = config;
    i = 0;
    while (i < len) {
      const onFulfilled = requestInterceptorChain[i++];
      const onRejected = requestInterceptorChain[i++];
      try {
        newConfig = onFulfilled(newConfig);
      } catch (error) {
        onRejected.call(this, error);
        break;
      }
    }
    try {
      promise = dispatchRequest.call(this, newConfig);
    } catch (error) {
      return Promise.reject(error);
    }
    i = 0;
    len = responseInterceptorChain.length;
    while (i < len) {
      promise = promise.then(responseInterceptorChain[i++], responseInterceptorChain[i++]);
    }
    return promise;
  }
  getUri(config) {
    config = mergeConfig(this.defaults, config);
    const fullPath = buildFullPath(config.baseURL, config.url);
    return buildURL(fullPath, config.params, config.paramsSerializer);
  }
}
utils$1.forEach(["delete", "get", "head", "options"], function forEachMethodNoData(method) {
  Axios.prototype[method] = function(url, config) {
    return this.request(mergeConfig(config || {}, {
      method,
      url,
      data: (config || {}).data
    }));
  };
});
utils$1.forEach(["post", "put", "patch"], function forEachMethodWithData(method) {
  function generateHTTPMethod(isForm) {
    return function httpMethod(url, data, config) {
      return this.request(mergeConfig(config || {}, {
        method,
        headers: isForm ? {
          "Content-Type": "multipart/form-data"
        } : {},
        url,
        data
      }));
    };
  }
  Axios.prototype[method] = generateHTTPMethod();
  Axios.prototype[method + "Form"] = generateHTTPMethod(true);
});
const Axios$1 = Axios;
class CancelToken {
  constructor(executor) {
    if (typeof executor !== "function") {
      throw new TypeError("executor must be a function.");
    }
    let resolvePromise;
    this.promise = new Promise(function promiseExecutor(resolve) {
      resolvePromise = resolve;
    });
    const token = this;
    this.promise.then((cancel) => {
      if (!token._listeners)
        return;
      let i = token._listeners.length;
      while (i-- > 0) {
        token._listeners[i](cancel);
      }
      token._listeners = null;
    });
    this.promise.then = (onfulfilled) => {
      let _resolve;
      const promise = new Promise((resolve) => {
        token.subscribe(resolve);
        _resolve = resolve;
      }).then(onfulfilled);
      promise.cancel = function reject() {
        token.unsubscribe(_resolve);
      };
      return promise;
    };
    executor(function cancel(message, config, request) {
      if (token.reason) {
        return;
      }
      token.reason = new CanceledError(message, config, request);
      resolvePromise(token.reason);
    });
  }
  /**
   * Throws a `CanceledError` if cancellation has been requested.
   */
  throwIfRequested() {
    if (this.reason) {
      throw this.reason;
    }
  }
  /**
   * Subscribe to the cancel signal
   */
  subscribe(listener) {
    if (this.reason) {
      listener(this.reason);
      return;
    }
    if (this._listeners) {
      this._listeners.push(listener);
    } else {
      this._listeners = [listener];
    }
  }
  /**
   * Unsubscribe from the cancel signal
   */
  unsubscribe(listener) {
    if (!this._listeners) {
      return;
    }
    const index = this._listeners.indexOf(listener);
    if (index !== -1) {
      this._listeners.splice(index, 1);
    }
  }
  /**
   * Returns an object that contains a new `CancelToken` and a function that, when called,
   * cancels the `CancelToken`.
   */
  static source() {
    let cancel;
    const token = new CancelToken(function executor(c) {
      cancel = c;
    });
    return {
      token,
      cancel
    };
  }
}
const CancelToken$1 = CancelToken;
function spread(callback) {
  return function wrap(arr) {
    return callback.apply(null, arr);
  };
}
function isAxiosError(payload) {
  return utils$1.isObject(payload) && payload.isAxiosError === true;
}
const HttpStatusCode = {
  Continue: 100,
  SwitchingProtocols: 101,
  Processing: 102,
  EarlyHints: 103,
  Ok: 200,
  Created: 201,
  Accepted: 202,
  NonAuthoritativeInformation: 203,
  NoContent: 204,
  ResetContent: 205,
  PartialContent: 206,
  MultiStatus: 207,
  AlreadyReported: 208,
  ImUsed: 226,
  MultipleChoices: 300,
  MovedPermanently: 301,
  Found: 302,
  SeeOther: 303,
  NotModified: 304,
  UseProxy: 305,
  Unused: 306,
  TemporaryRedirect: 307,
  PermanentRedirect: 308,
  BadRequest: 400,
  Unauthorized: 401,
  PaymentRequired: 402,
  Forbidden: 403,
  NotFound: 404,
  MethodNotAllowed: 405,
  NotAcceptable: 406,
  ProxyAuthenticationRequired: 407,
  RequestTimeout: 408,
  Conflict: 409,
  Gone: 410,
  LengthRequired: 411,
  PreconditionFailed: 412,
  PayloadTooLarge: 413,
  UriTooLong: 414,
  UnsupportedMediaType: 415,
  RangeNotSatisfiable: 416,
  ExpectationFailed: 417,
  ImATeapot: 418,
  MisdirectedRequest: 421,
  UnprocessableEntity: 422,
  Locked: 423,
  FailedDependency: 424,
  TooEarly: 425,
  UpgradeRequired: 426,
  PreconditionRequired: 428,
  TooManyRequests: 429,
  RequestHeaderFieldsTooLarge: 431,
  UnavailableForLegalReasons: 451,
  InternalServerError: 500,
  NotImplemented: 501,
  BadGateway: 502,
  ServiceUnavailable: 503,
  GatewayTimeout: 504,
  HttpVersionNotSupported: 505,
  VariantAlsoNegotiates: 506,
  InsufficientStorage: 507,
  LoopDetected: 508,
  NotExtended: 510,
  NetworkAuthenticationRequired: 511
};
Object.entries(HttpStatusCode).forEach(([key, value]) => {
  HttpStatusCode[value] = key;
});
const HttpStatusCode$1 = HttpStatusCode;
function createInstance(defaultConfig) {
  const context = new Axios$1(defaultConfig);
  const instance = bind(Axios$1.prototype.request, context);
  utils$1.extend(instance, Axios$1.prototype, context, { allOwnKeys: true });
  utils$1.extend(instance, context, null, { allOwnKeys: true });
  instance.create = function create(instanceConfig) {
    return createInstance(mergeConfig(defaultConfig, instanceConfig));
  };
  return instance;
}
const axios = createInstance(defaults$1);
axios.Axios = Axios$1;
axios.CanceledError = CanceledError;
axios.CancelToken = CancelToken$1;
axios.isCancel = isCancel;
axios.VERSION = VERSION;
axios.toFormData = toFormData;
axios.AxiosError = AxiosError;
axios.Cancel = axios.CanceledError;
axios.all = function all(promises) {
  return Promise.all(promises);
};
axios.spread = spread;
axios.isAxiosError = isAxiosError;
axios.mergeConfig = mergeConfig;
axios.AxiosHeaders = AxiosHeaders$1;
axios.formToJSON = (thing) => formDataToJSON(utils$1.isHTMLForm(thing) ? new FormData(thing) : thing);
axios.getAdapter = adapters.getAdapter;
axios.HttpStatusCode = HttpStatusCode$1;
axios.default = axios;
let recording = false;
function main() {
  const data = {
    serverId: 0,
    playerId: "",
    playerServerId: 0
  };
  let renderer = null;
  window.addEventListener("message", (event) => {
    if (event.data.action === "init") {
      const { serverId, playerId, playerServerId } = event.data;
      data.serverId = serverId;
      data.playerId = playerId;
      data.playerServerId = playerServerId;
      window.data = data;
    } else if (event.data.action === "record") {
      if (recording)
        return console.error("in progress");
      if (!renderer) {
        renderer = new GameViewRenderer();
      }
      const {
        url,
        duration
        /*, fps, bitrate*/
      } = event.data;
      if (!url)
        return console.error("no url provided");
      if (!duration)
        return console.error("no duration provided");
      const recorder = RecordRTC(renderer.finalCanvas.captureStream(), {
        type: "video",
        /*videoBitsPerSecond: bitrate || 2_000,
        frameRate: fps || 25,*/
        disableLogs: true
      });
      recording = true;
      recorder.startRecording();
      setTimeout(() => {
        recorder.stopRecording(() => {
          recording = false;
          const form = new FormData();
          form.append("files[]", recorder.getBlob(), "screen_recording.webm");
          axios.post(url, form).catch(() => {
          }).finally(() => {
            renderer == null ? void 0 : renderer.destroy();
            renderer = null;
          });
        });
      }, duration * 1e3);
    }
  });
  axios.get(`https://${GetParentResourceName()}/ready`);
}
main();
