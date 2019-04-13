/*  Duane Shaffer
    CS 443 Spring 2019 
    Dr. Kenrick Mock
    Problem 5 - This is a simple ray tracer that shoots rays top down toward randomly generated spheres and 
                draws the sphere in a random color based on where the ray hits it.
    Based off code given by Dr. Mock. My task is to accelerate it using the GPU
    Time without acceleration: 3.907 sec
    Time with cuda acceleration: 
*/

#include "FreeImage.h"
#include "stdio.h"

#define DIM 256
#define rnd(x) (x * rand() / RAND_MAX)
#define INF 2e10f

struct Sphere {
                            float   r,b,g;
                            float   radius;
                            float   x,y,z;
                            // Tells us if a ray hits the sphere; return the
                            // depth of the hit, or -infinity if the ray misses the sphere
                            __device__ __host__ float hit( float ox, float oy, float *n ) 
                            {
                                float dx = ox - x;
                                float dy = oy - y;
                                if (dx*dx + dy*dy < radius*radius)
                                {
                                    float dz = sqrtf( radius*radius - dx*dx - dy*dy );
                                    *n = dz / sqrtf( radius * radius );
                                    return dz + z;
                                }
                                return -INF;
                            }
                        };

#define SPHERES 80


__global__ void gpu_drawSpheres(Sphere *spheres, char *red, char *green, char *blue) {
    // for (int x = 0; x < DIM; x++) { // x = blockIdx.x switch with y
        // for (int y = 0; y < DIM; y++) { // y = threadIdx.x
            float   ox = (blockIdx.x - DIM/2);
            float   oy = (threadIdx.x - DIM/2);

            float   r=0, g=0, b=0;
            float   maxz = -INF;
	        for(int i=0; i<SPHERES; i++) {
                float   n;
                float   t = spheres[i].hit( ox, oy, &n );
                if (t > maxz) {
			        // Scale RGB color based on z depth of sphere
            		float fscale = n;
            		r = spheres[i].r * fscale;
            		g = spheres[i].g * fscale;
            		b = spheres[i].b * fscale;
            		maxz = t;
        	    }
            }
            int offset = threadIdx.x + blockIdx.x * DIM;
            // printf("%d, %d, offset: %d\n", threadIdx.x, blockIdx.x, offset);
            red[offset] = (char) (r * 255);
            green[offset] = (char) (g * 255);
            blue[offset] = (char) (b * 255);
        // }
    // }
}

// Loops through each pixel in the image (represented by arrays of
// red, green, and blue) and then for each pixel checks if a ray from
// top down hits one of the randomly generated spheres.
// If so, calculate a shade of color based on where the ray hits it.
void drawSpheres(Sphere spheres[], char *red, char *green, char *blue){
    Sphere *dev_spheres;
    char *dev_red;
    char *dev_green;
    char *dev_blue;
    cudaMalloc((void**) &dev_spheres, SPHERES*sizeof(Sphere));
    cudaMalloc((void**) &dev_red, DIM*DIM*sizeof(char));
    cudaMalloc((void**) &dev_green, DIM*DIM*sizeof(char));
    cudaMalloc((void**) &dev_blue, DIM*DIM*sizeof(char));
    cudaMemcpy(dev_spheres, spheres, SPHERES*sizeof(char), cudaMemcpyHostToDevice);
    cudaMemcpy(dev_red, red, DIM*DIM*sizeof(char), cudaMemcpyHostToDevice);
    cudaMemcpy(dev_green, green, DIM*DIM*sizeof(char), cudaMemcpyHostToDevice);
    cudaMemcpy(dev_blue, blue, DIM*DIM*sizeof(char), cudaMemcpyHostToDevice);

    dim3 blocks(2048, 1);
    dim3 grids(2048, 1)

    gpu_drawSpheres<<<grids, blocks,1>>>(dev_spheres, dev_red, dev_green, dev_blue);


    cudaMemcpy(red, dev_red,DIM*DIM*sizeof(char), cudaMemcpyDeviceToHost);
    cudaMemcpy(green, dev_green, DIM*DIM*sizeof(char), cudaMemcpyDeviceToHost);
    cudaMemcpy(blue, dev_blue, DIM*DIM*sizeof(char), cudaMemcpyDeviceToHost);
    cudaFree(dev_spheres);
    cudaFree(dev_red);
    cudaFree(dev_blue);
    cudaFree(dev_green);
    
}

int main() {
  FreeImage_Initialise();
  atexit(FreeImage_DeInitialise);
  FIBITMAP * bitmap = FreeImage_Allocate(DIM, DIM, 24);
  srand(time(NULL));

  char *red;
  char *green;
  char *blue;

  // Dynamically create enough memory for DIM * DIM array of char.
  // By making these dynamic rather than auto (e.g. char red[DIM][DIM])
  // we can make them much bigger since they are allocated off the heap
  red = (char *) malloc(DIM*DIM*sizeof(char));
  green = (char *) malloc(DIM*DIM*sizeof(char));
  blue = (char *) malloc(DIM*DIM*sizeof(char));

  // Create random spheres at different coordinates, colors, radius
  Sphere spheres[SPHERES];
  for (int i = 0; i<SPHERES; i++) {
        spheres[i].r = rnd( 1.0f );
        spheres[i].g = rnd( 1.0f );
        spheres[i].b = rnd( 1.0f );
        spheres[i].x = rnd( (float) DIM ) - (DIM/2.0);
        spheres[i].y = rnd( (float) DIM ) - (DIM/2.0);
        spheres[i].z = rnd( (float) DIM ) - (DIM/2.0);
        spheres[i].radius = rnd( 200.0f ) + 40;
  }
  drawSpheres(spheres, red, green, blue);

  RGBQUAD color;
  for (int i = 0; i < DIM; i++)
  {
    for (int j = 0; j < DIM; j++)
    {
      int index = j*DIM + i;
      color.rgbRed = red[index];
      color.rgbGreen = green[index];
      color.rgbBlue = blue[index];
      FreeImage_SetPixelColor(bitmap, i, j, &color);
    }
  }
	
  FreeImage_Save(FIF_PNG, bitmap, "ray.png", 0);
  FreeImage_Unload(bitmap);
  free(red);
  free(green);
  free(blue);

  return 0;
}