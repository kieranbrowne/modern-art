mat2 rotate(float theta) {
  return mat2(cos(theta), -sin(theta),sin(theta),cos(theta));
}


float noise(vec2 p) {
  return fract(sin(dot(p, vec2(12.9898,126.7378)))
               * 43758.5453) * 2.0-1.0;
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

float ngon(vec2 uv, vec2 pos, int n) {
  uv += pos;
  float a = atan(uv.x,uv.y)+3.145;
  float r = 6.28/float(n);
  return cos(floor(.5+a/r)*r-a)*length(uv);
}

































vec3 thing(vec3 c, vec3 col, vec2 pos, vec2 uv, float r) {

  c = mix(c, col, smoothstep(r,r-.01,ngon(uv+cnoise(uv/2.)/20., pos,95)));
  c = mix(c, col+vec3(0.,.3,0.), smoothstep(r+.04,r-.1,ngon(uv+cnoise(uv/2.)/20., pos,95)));
  c = mix(c, col+vec3(-.07,0.14,0.3), smoothstep(r+.04,.0,ngon(uv+cnoise(uv*3.)/30., pos,95)));

  return c;
}



void main () {
  vec2 uv = (gl_FragCoord.xy-.5*iResolution.xy) / iResolution.y * 2.;


  vec3 c = vec3(.09,.00,0.00);
  //c = vec3(0.33,.24,0.9);
  // grid
  c = mix(c, vec3(1.0), smoothstep(.8,1.4,cos(uv*100.).x)* smoothstep(.0,.9,cos(uv*100.).y));
  c = mix(c, vec3(1.0), smoothstep(.8,1.4,cos(uv*100.).y)* smoothstep(.0,.9,cos(uv*100.).x));




  c = mix(c, vec3(0.3,.4,.8), smoothstep(.1,.9,cnoise(uv*1.8)+noise(uv*2.)/14.+noise(uv)/14.));
  c = mix(c, vec3(0.9,.8,.0), smoothstep(.5,1.3,cnoise(uv*2.9)+noise(uv*2.)/14.+noise(uv)/4.));


  c = mix(c, vec3(1.0,.2,.0), smoothstep(.8,1.4,cos(uv*100.).y)* smoothstep(.0,.9,cos(uv*100.).x) * smoothstep(-.2,.0,cnoise(uv*1.8)+noise(uv*2.)/14.+noise(uv)/14.));


  //uv*=rotate(1.);
  // uv+=vec2(cnoise(uv*2.+iGlobalTime*vec2(1.,0.))/40.);


  for(float i=-1.; i< 1.; i+= .2) {
    for(float j=-1.; j< 1.; j+= .2) {
      c = mix(c,thing(c, vec3(1.0,.6,.0), vec2(i,j), uv, .1), 1.-smoothstep(0.,1.9,length(uv+vec2(i+.9,-j))+ tan(i*2.+10.+j*9.) +tan(j*2./2. -i*10.)));
    }
  }
  c = mix(c,thing(c, vec3(1.,.2,.3), vec2(.0,.0), uv, .9), length(uv+vec2(1.,0.)));


  // c = mix(c,thing(c, vec3(.2,.9,.9), vec2(-.05,.0), uv, .8), 1.-length(uv+vec2(1.,0.)));
  c = mix(c,thing(c, vec3(.1,.9,.9), vec2(1.25,.3), uv, .50), -length(uv+vec2(1.,0.)));
  // c = mix(c,thing(c, vec3(.0,.1,0.), vec2(-.1,.0), uv, .6), 1.-length(uv+vec2(1.,0.)));
  c = mix(c,thing(c, vec3(.2,.3,.9), vec2(-.4,.0), uv, .5), length(uv+vec2(.1,0.)));
  // c = mix(c,thing(c, vec3(1.0,1.0,.10), vec2(1.5,.9), uv, 1.2), smoothstep(.4,.39,ngon(uv*vec2(1.3,0.9)*rotate(.2),vec2(1.3,.4), 3))-.01);
  c = mix(c,thing(c, vec3(.1,.1,1.), vec2(.9,-.7), uv, .3), smoothstep(.3,.4,ngon(uv,vec2(1.,-1.),3)));
  // c = mix(c,thing(c, vec3(.0,.1,.2), vec2(-1.4,.8), uv, .4), 1-length(uv+vec2(1.,0.)));
  c= mix(c,thing(c, vec3(.9,.1,.1), vec2(-1.4,.8), uv, .4), length(uv+vec2(1.,0.)));


  // c = mix(c,thing(c, vec3(1.,1.,1.), vec2(-.9,.1), uv, .4), 1.-length(uv));
  // c = mix(c,thing(c, vec3(1.,1.,1.), vec2(-.9,.1), uv, .2), 1.-length(uv));

  // c = mix(c,thing(c, vec3(1.,1.,1.), vec2(.9,.1), uv, .4), 1.-length(uv));
  // c = mix(c,thing(c, vec3(1.,1.,1.), vec2(.9,.1), uv, .3), 1.-length(uv));

  // c = thing(c, vec3(0.,.0,1.), vec2(-.3,.4), uv, .2);
  // c = thing(c, vec3(0.,.0,1.), vec2(-.0,.4), uv, .2);

  // c = thing(c, vec3(1.,.0,.0), vec2(-.3,.0), uv, .2);

  // c = thing(c, vec3(1.,.0,.0), vec2(-.3,-.4), uv, .2);

  //c += smoothstep(.48,.8,noise(uv)/2.)*20.

  gl_FragColor = vec4(c, 1.);
}


