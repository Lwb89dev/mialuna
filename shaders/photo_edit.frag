// Live preview of the photo editor. Mirrors, step by step, the export in
// lib/features/create/editor/image_edit_apply.dart (renderEdit) and the
// helpers in color_engine.dart: change one, change the other.
#version 460 core

#include <flutter/runtime_effect.glsl>

precision highp float;

uniform vec2 uSize;       // output size in logical pixels
uniform vec2 uSrcTexel;   // 1 / source texture size
uniform vec2 uFrame;      // turned frame size in source pixels
uniform vec4 uGeo;        // quarter turns, mirror (0/1), angle (rad), cover scale
uniform vec4 uCrop;       // crop left, top, right, bottom (frame fractions)
uniform vec4 uFx;         // sharpen, vignette, grain, use LUT (0/1)
uniform vec2 uGrainCells; // grain cells across the crop, x and y
uniform float uLutN;      // LUT points per axis
uniform float uShowCrop;  // 1 = draw only the crop, 0 = the whole frame

uniform sampler2D uSrc;
uniform sampler2D uLut;

out vec4 fragColor;

vec2 sourceOf(vec2 uv) {
  vec2 f = uv;
  float angle = uGeo.z;
  if (angle != 0.0) {
    vec2 p = (uv - 0.5) * uFrame;
    float c = cos(angle);
    float s = sin(angle);
    vec2 q = vec2(c * p.x + s * p.y, -s * p.x + c * p.y) / uGeo.w;
    f = q / uFrame + 0.5;
  }
  if (uGeo.y > 0.5) f.x = 1.0 - f.x;
  int turns = int(uGeo.x + 0.5);
  if (turns == 1) return vec2(f.y, 1.0 - f.x);
  if (turns == 2) return vec2(1.0 - f.x, 1.0 - f.y);
  if (turns == 3) return vec2(1.0 - f.y, f.x);
  return f;
}

vec3 lutAt(float r, float g, float b) {
  float n = uLutN;
  return texture(uLut, vec2((b * n + r + 0.5) / (n * n), (g + 0.5) / n)).rgb;
}

vec3 applyLut(vec3 c) {
  float s = uLutN - 1.0;
  vec3 f = clamp(c, 0.0, 1.0) * s;
  vec3 i = min(floor(f), vec3(s - 1.0));
  vec3 t = f - i;
  vec3 c000 = lutAt(i.r, i.g, i.b);
  vec3 c100 = lutAt(i.r + 1.0, i.g, i.b);
  vec3 c010 = lutAt(i.r, i.g + 1.0, i.b);
  vec3 c110 = lutAt(i.r + 1.0, i.g + 1.0, i.b);
  vec3 c001 = lutAt(i.r, i.g, i.b + 1.0);
  vec3 c101 = lutAt(i.r + 1.0, i.g, i.b + 1.0);
  vec3 c011 = lutAt(i.r, i.g + 1.0, i.b + 1.0);
  vec3 c111 = lutAt(i.r + 1.0, i.g + 1.0, i.b + 1.0);
  vec3 y0 = mix(mix(c000, c100, t.r), mix(c010, c110, t.r), t.g);
  vec3 y1 = mix(mix(c001, c101, t.r), mix(c011, c111, t.r), t.g);
  return mix(y0, y1, t.b);
}

float hash12(vec2 p) {
  vec3 p3 = fract(vec3(p.xyx) * 0.1031);
  p3 += dot(p3, p3.yzx + 33.33);
  return fract((p3.x + p3.y) * p3.z);
}

float grainNoise(vec2 x) {
  vec2 i = floor(x);
  vec2 f = x - i;
  f = f * f * (3.0 - 2.0 * f);
  float a = hash12(i);
  float b = hash12(i + vec2(1.0, 0.0));
  float c = hash12(i + vec2(0.0, 1.0));
  float d = hash12(i + vec2(1.0, 1.0));
  return mix(mix(a, b, f.x), mix(c, d, f.x), f.y) - 0.5;
}

void main() {
  vec2 local = FlutterFragCoord().xy / uSize;
  vec2 cropSize = uCrop.zw - uCrop.xy;
  vec2 uv = uShowCrop > 0.5 ? uCrop.xy + local * cropSize : local;
  vec2 src = sourceOf(uv);
  vec4 px = texture(uSrc, src);
  vec3 c = px.rgb;

  if (uFx.x > 0.0) {
    vec3 n = texture(uSrc, src + vec2(0.0, -uSrcTexel.y)).rgb;
    vec3 s = texture(uSrc, src + vec2(0.0, uSrcTexel.y)).rgb;
    vec3 e = texture(uSrc, src + vec2(uSrcTexel.x, 0.0)).rgb;
    vec3 w = texture(uSrc, src + vec2(-uSrcTexel.x, 0.0)).rgb;
    c = clamp(c + (4.0 * c - n - s - e - w) * uFx.x * 0.6, 0.0, 1.0);
  }

  if (uFx.w > 0.5) c = applyLut(c);

  vec2 cu = (uv - uCrop.xy) / cropSize;
  if (uFx.y != 0.0) {
    vec2 d = (cu - 0.5) * 2.0;
    float m = smoothstep(0.25, 1.05, length(d) / sqrt(2.0)) * abs(uFx.y) * 0.85;
    c = uFx.y < 0.0 ? c * (1.0 - m) : c + (1.0 - c) * m;
  }
  if (uFx.z != 0.0) {
    c += grainNoise(cu * uGrainCells) * uFx.z * 0.22;
  }

  c = clamp(c, 0.0, 1.0);
  fragColor = vec4(c * px.a, px.a);
}
