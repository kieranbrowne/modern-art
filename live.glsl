#define S(a,b,x) smoothstep(a,b,x)
mat2 rotate(float theta) {
  return mat2(cos(theta), -sin(theta),sin(theta),cos(theta));
}

// pixel pos
vec2 uv = (gl_FragCoord.xy-.5*iResolution.xy) / iResolution.y * 2.;
// background color
vec3 c = vec3(.99,.9,.8);

//c.yx *= rotate(1.);


mat3 yuv = mat3(1., 0., 1.13983, 1., -.39465, -.5806, 1., 2.03211, 0.);


float noise(vec2 p) {
  return fract(sin(dot(p, vec2(12.9898,126.7378)))
               * 43758.5453) * 2.0-1.0;
}


float ngon(vec2 uv, vec2 pos, int n) {
  uv += pos;
  float a = atan(uv.x,uv.y)+3.145;
  float r = 6.28/float(n);
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

float sdBox( in vec2 p, in vec2 b )
{
  vec2 d = abs(p)-b;
  return length(max(d,vec2(0))) + min(max(d.x,d.y),0.0);
}


void draw(vec3 color, float norm) {
  c = mix(c, color, max(0.,norm));
}


void main () {


  draw(vec3(.11),smoothstep(.0,0.,length(uv)));

  vec2 suv = uv;

  float p = 1.05;
  float d = 2.19;

  if(uv.y<=0.)
    suv.y+= min(.80,ngon(uv*vec2(2.1,1.)*rotate(3.1415*.75),vec2(p,-p),4))/d;

  else if(uv.y>0.)
    suv.y-= min(.80,ngon(uv*vec2(2.1,1.)*rotate(3.1415*.75),vec2(p,-p),4))/d;


  if(uv.y<=0.)
    suv.y+= min(.8,ngon((uv*vec2(2.1,1.))*rotate(3.1415*.75),-vec2(p,-p),4))/d;

  else if(uv.y>0.)
    suv.y-= min(.8,ngon(uv*vec2(2.1,1.)*rotate(3.1415*.75),-vec2(p,-p),4))/d;



  suv+= cnoise(uv*40.)/920.;
  suv+= cnoise(uv*90.)/720.;


  // uv.y+= pow(min(.4,ngon(uv,vec2(-0.2,-.8),90))*1.,2.);
  // uv.y+= pow(min(.4,ngon(uv,vec2(0.4,.1),90))*1.,2.);

  draw(vec3(.99),smoothstep(.7,1.,cos(suv.y*120.)));

  c += cnoise(suv*vec2(1.,19.)*19.)/3.;

  c += cnoise(suv*vec2(1.,4.)*99.)/4.;





  gl_FragColor = vec4(c, 1.);
}
