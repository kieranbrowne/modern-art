mat2 rotate(float theta) {
  return mat2(cos(theta), -sin(theta),sin(theta),cos(theta));
}

// pixel pos
vec2 uv;
// background color
vec3 c = vec3(.32,.29,0.00);

//c.yx *= rotate(1.);


mat3 yuv = mat3(1., 0., 1.13983, 1., -.39465, -.5806, 1., 2.03211, 0.);


float noise(vec2 p) {
  return fract(sin(dot(p, vec2(12.9898,126.7378)))
               * 43758.5453) * 2.0-1.0;
}


float ngon(vec2 pos, int n) {
  vec2 tuv = uv + pos;
  float a = atan(tuv.x,tuv.y)+3.145;
  float r = 6.28/float(n);
  return cos(floor(.5+a/r)*r-a)*length(tuv);
}

float circle(vec2 pos) {
  return length(uv+pos);
}


vec2 fade(vec2 t) {return t*t*t*(t*(t*6.0-15.0)+10.0);}
vec4 permute(vec4 x){return mod(((x*34.0)+1.0)*x, 289.0);}
vec4 taylorInvSqrt(vec4 r){return 1.79284291400159 - 0.85373472095314 * r;}
vec3 fade(vec3 t) {return t*t*t*(t*(t*6.0-15.0)+10.0);}

float cnoise(vec2 P){
  vec4 Pi = floor(P.xyxy) + vec4(0.0, 0.0, 1.0, 1.0);
  vec4 Pf = fract(P.xyxy) - vec4(0.0, 0.0, 1.0, 1.0);
  Pi = mod(Pi, 289.0); // To avoid truncation effects in permutation
  vec4 ix = Pi.xzxz;
  vec4 iy = Pi.yyww;
  vec4 fx = Pf.xzxz;
  vec4 fy = Pf.yyww;
  vec4 i = permute(permute(ix) + iy);
  vec4 gx = 2.0 * fract(i * 0.0243902439) - 1.0; // 1/41 = 0.024...
  vec4 gy = abs(gx) - 0.5;
  vec4 tx = floor(gx + 0.5);
  gx = gx - tx;
  vec2 g00 = vec2(gx.x,gy.x);
  vec2 g10 = vec2(gx.y,gy.y);
  vec2 g01 = vec2(gx.z,gy.z);
  vec2 g11 = vec2(gx.w,gy.w);
  vec4 norm = 1.79284291400159 - 0.85373472095314 *
    vec4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11));
  g00 *= norm.x;
  g01 *= norm.y;
  g10 *= norm.z;
  g11 *= norm.w;
  float n00 = dot(g00, vec2(fx.x, fy.x));
  float n10 = dot(g10, vec2(fx.y, fy.y));
  float n01 = dot(g01, vec2(fx.z, fy.z));
  float n11 = dot(g11, vec2(fx.w, fy.w));
  vec2 fade_xy = fade(Pf.xy);
  vec2 n_x = mix(vec2(n00, n01), vec2(n10, n11), fade_xy.x);
  float n_xy = mix(n_x.x, n_x.y, fade_xy.y);
  return 2.3 * n_xy;
}






























void draw(vec3 color, float norm) {
  c = mix(c, color, max(0.,norm));
}


void main () {
  uv = (gl_FragCoord.xy-.5*iResolution.xy) / iResolution.y * 2.;

  draw(vec3(0.30,0.24,0.12)*1.3, smoothstep(1.0,.4,ngon(vec2(0.), 4)));
  draw(vec3(0.32,0.29,0.0)*.9, smoothstep(.97,1.,ngon(vec2(0.), 4)));

  c += cnoise(uv*90.)/32.*cnoise(uv*2.)+cnoise(uv*190.)/92.*(1.+cnoise(uv*4.));
  //draw(vec3(1.,0.,1.),.1+cnoise(uv*64.)*0.05+noise(uv)*.04);

  draw(vec3(.73,0.18,0.08)+cnoise(uv*40.)/70.+cnoise(uv*100.)/70.,
       smoothstep(.9,.88,ngon(vec2(0.), 4))
       * smoothstep(.6,.62,ngon(vec2(0.), 4))
       + smoothstep(.42,.40,ngon(vec2(0.), 4))
       * smoothstep(.20,.22,ngon(vec2(0.), 4))
       * smoothstep(.12,.14,ngon(vec2(0.29, .082), 4))
       * smoothstep(.12,.14,ngon(vec2(0.29, .082)*rotate(3.14), 4))
       * smoothstep(.12,.14,ngon(vec2(0.29, .082)*rotate(3.14*1.5), 4))
       * smoothstep(.12,.14,ngon(vec2(0.29, .082)*rotate(3.14*.5), 4))
       );

  draw(vec3(.83,0.23,0.38)+cnoise(uv*90.)/22.+cnoise(uv*190.)/22.,
       smoothstep(.9,.58,ngon(vec2(0.), 4))
       * smoothstep(.6,.82,ngon(vec2(0.), 4))
       + smoothstep(.42,.12,ngon(vec2(0.), 4))
       * smoothstep(.20,.22,ngon(vec2(0.), 4))
       * smoothstep(.30,.32,ngon(vec2(0.), 4))
       * smoothstep(.12,.14,ngon(vec2(0.29, .082), 4))
       * smoothstep(.12,.14,ngon(vec2(0.29, .082)*rotate(3.14), 4))
       * smoothstep(.12,.14,ngon(vec2(0.29, .082)*rotate(3.14*1.5), 4))
       * smoothstep(.12,.14,ngon(vec2(0.29, .082)*rotate(3.14*.5), 4))
       );

  if(uv.x+uv.y>0.) {
    uv *= rotate(3.14*-.5);
  }
  draw(vec3(.0,.2,.3)+cnoise(uv*80)*.02+cnoise(uv*120)*.02,
       smoothstep(.87,.9,max(0.,cos(uv.y*6.2 +3.14)))
       * smoothstep(.00,.99,ngon(vec2(0.), 4))
       * smoothstep(.60,.61,ngon(vec2(0.), 4))
       );
  draw(vec3(.0,.3,.4)+cnoise(uv*80)*.02+cnoise(uv*120)*.02,
       smoothstep(.87,.9,max(0.,cos(uv.y*6.2 +3.14)))
       * smoothstep(.90,.99,ngon(vec2(0.), 4))
       * smoothstep(.60,.81,ngon(vec2(0.), 4))
       -.0
       );

  if(-uv.x+uv.y>0.) {
    uv *= rotate(3.14159*1.5);
  }

  draw(vec3(.9,.3,.3)+cnoise(uv*80)*.02+cnoise(uv*120)*.02,
       smoothstep(.77,.8,max(0.,cos(uv.y*8.4 )))
       * smoothstep(.60,.61,ngon(vec2(0.), 4))
       * smoothstep(.09,.10,abs(uv.x))
       * smoothstep(.9,.89,abs(uv.x))
       -.1
       );

  draw(vec3(.9,.3,.3)+cnoise(uv*80)*.02+cnoise(uv*120)*.02,
       smoothstep(.77,.8,max(0.,sin(uv.y*9.4 )))
       * smoothstep(.60,.61,ngon(vec2(0.), 4))
       * smoothstep(.39,.30,abs(uv.x))
       * smoothstep(.29,.28,abs(uv.x))
       -.1
       );

  draw(vec3(.0,.4,.4)+cnoise(uv*20.)/2.,
       smoothstep(.0,1.9,max(0.,cos((uv+cnoise(uv*.49)).y*93. + 3.14)))
       * smoothstep(1.,.999,ngon(vec2(0.), 4))
       * smoothstep(.59,.58,ngon(vec2(0.), 4))
       -.1
       );

  gl_FragColor = vec4(c, 1.);
}


