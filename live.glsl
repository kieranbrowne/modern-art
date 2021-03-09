#define S(a,b,x) smoothstep(a,b,x)
#define PI 3.14159265359

float t = iGlobalTime;

mat2 rotate(float theta) {
  return mat2(cos(theta), -sin(theta),sin(theta),cos(theta));
}

mat2 identity = mat2(1.,0.,0.,1.);

// pixel pos
vec2 uv = (gl_FragCoord.xy-.5*iResolution.xy) / iResolution.y * 2.;
// background color
vec3 c = vec3(.85,.83,.80);

//c.yx *= rotate(1.);


mat3 yuv = mat3(1., 0., 1.13983, 1., -.39465, -.5806, 1., 2.03211, 0.);


float noise(vec2 p) {
  return fract(sin(dot(p, vec2(12.9898,126.7378)))
               * 43758.5453) * 2.0-1.0;
}


float ngon(vec2 uv, vec2 pos, int n) {
  uv += pos;
  float a = atan(uv.x,uv.y)+PI;
  float r = PI*2./float(n);
  return cos(floor(.5+a/r)*r-a)*length(uv);
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

























float smin( float a, float b, float k )
{
  float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
  return mix( b, a, h ) - k*h*(1.0-h);
}

// float smin( float a, float b, float k )
// {
//   a = pow( a, k ); b = pow( b, k );
//   return pow( (a*b)/(a+b), 1.0/k );
// }

float sdBox( in vec2 p, in vec2 b ) {
  vec2 d = abs(p)-b;
  return length(max(d,vec2(0))) + min(max(d.x,d.y),0.0);
}

float line( in vec2 p, in vec2 a, in vec2 b ) {
  vec2 pa = p-a, ba = b-a;
  float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
  return length( pa - ba*h );
}


void draw(vec3 color, float norm) {
  c = mix(c, color, max(0.,norm));
}

void thing1(vec2 off, float rot) {
  draw(vec3(.99,.9,.8), S(.005,.0,line((uv+off)*rotate(rot), vec2(-0.125*0, -0.125*1), vec2(-.125*1.,-.125*0.))));
}

void thing2(vec2 off, float rot) {
  draw(vec3(.99,.9,.8), S(.005,.0,abs(.125-length(uv+off))));
}

void thing(vec2 pos) {
  draw(vec3(.9,.3,.2)+cnoise(uv*150.)/20., S(pos.y,pos.y + .04,uv.y)*S(pos.y+1.04,pos.y+1.,uv.y)*S(pos.x,pos.x+1.,uv.x)*S(pos.x+ 1.1,pos.x+1.,uv.x)*(1.+cnoise(uv*10.)/2. +cnoise(uv*170.)/4.));
}

void main () {


  draw(vec3(.9,.9,.88), 1.);

  vec2 gv = fract(uv*4.)-.5;
  vec2 gn = floor(uv*4.);


  //thing(vec2(.3, .6));

  //draw(vec3(.1), S(0.41,0.4,ngon(gv + cnoise(gv*1. + gv*2. + gn)*.02, vec2(0.), 4 )));


  draw(vec3(.9,1.0,.1)*1., S(.9,.0,sdBox(uv,vec2(.10))));
  draw(vec3(.9,.80,.7)*1.2, S(.09,.0,sdBox(uv,vec2(.30))));
  uv += vec2(cnoise(uv*8.),cnoise(uv*8.)*1.)*.01 ;
  draw(vec3(.9,0.9,.9), S(-.1,.3,sdBox(uv,vec2(0.4))));
  uv += vec2(cnoise(uv*18.),cnoise(uv*18.)*1.)*.01 ;
  uv += vec2(cnoise(uv*58.),cnoise(uv*58.)*1.)*.01 ;
  draw(vec3(1.,1.0,.4), S(.0,.7,sdBox(uv,vec2(0.4))));
  //uv += vec2(cnoise(uv*108.),cnoise(uv*108.)*1.)*.02 ;
  draw(vec3(.4,0.9,.4)*1.4, S(.1,.49,sdBox(uv,vec2(0.6))));


  //draw(vec3(.6,0.5,.9), S(.1,.49,sdBox(uv,vec2(0.6))));
  //draw(vec3(.1,0.2,.4), S(.0,.1,sdBox(uv,vec2(0.8))));

  //draw(vec3(.9,.9,.88)*.8, cnoise(uv*100.)/7.);
  //draw(vec3(.9,.9,.88)*.8, cnoise(uv*140. +cnoise(uv*3.))/3.);


  //draw(vec3(.9), S(.002,0., mod(uv.x,0.1) ) + S(.002,0., mod(uv.y,0.1) ));


  gl_FragColor = vec4(c, 1.);
}
