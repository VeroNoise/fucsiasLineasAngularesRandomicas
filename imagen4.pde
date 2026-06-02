PImage photo;
float[][] offsetX;
float[][] offsetY;
ArrayList<ArrayList<PVector>> ramas;
// Solución al error: Usamos un ArrayList simple de colores (int)
ArrayList<Integer> coloresRama; 
int contadorVioletas;

void setup() {
  size(940, 520);
  background(255);
  photo = loadImage("doss.jpg");
  
  int step = 20;
  int gridX = width / step + 1;
  int gridY = height / step + 1;
  
  offsetX = new float[gridX][gridY];
  offsetY = new float[gridX][gridY];
  
  // Inicialización correcta de las listas
  ramas = new ArrayList<ArrayList<PVector>>();
  coloresRama = new ArrayList<Integer>();
  
  inicializar();
}

void inicializar() {
  int step = 20;
  int gridX = width / step + 1;
  int gridY = height / step + 1;
  
  for (int i = 0; i < gridX; i++) {
    for (int j = 0; j < gridY; j++) {
      offsetX[i][j] = 0;
      offsetY[i][j] = 0;
    }
  }
  
  ramas.clear();
  coloresRama.clear();
  
  // Llenar las listas con datos vacíos iniciales
  for (int i = 0; i < gridX; i++) {
    for (int j = 0; j < gridY; j++) {
      ArrayList<PVector> rama = new ArrayList<PVector>();
      rama.add(new PVector(0, 0));
      ramas.add(rama);
      coloresRama.add(color(0));
    }
  }
}

void mousePressed() {
  inicializar();
}

void draw() {
  background(0); // Fondo negro para efecto "glow"
  image(photo, 0, 0);
  
  int step = 20;
  contadorVioletas = 0;
  int index = 0;
  
  int gridX = width / step + 1;
  int gridY = height / step + 1;
  
  for (int x = 0; x < width; x += step) {
    for (int y = 0; y < height; y += step) {
      int c = photo.get(x, y);
      float r = red(c);
      float g = green(c);
      float b = blue(c);
      
      // Detectar Violetas y Azules
      boolean esVioleta = (r > 100 && b > 100 && g < 100);
      boolean esAzul = (b > 150 && r < 100 && g < 100);
      boolean esPuntoInteres = esVioleta || esAzul;
      
      int ix = x / step;
      int iy = y / step;
      
      if (ix < gridX && iy < gridY) {
        float nuevoX = x + offsetX[ix][iy];
        float nuevoY = y + offsetY[ix][iy];
        
        if (esPuntoInteres) {
          contadorVioletas++;
          
          // Movimiento aleatorio
          offsetX[ix][iy] += random(-1, 1);
          offsetY[ix][iy] += random(-1, 1);
          offsetX[ix][iy] = constrain(offsetX[ix][iy], -5, 5);
          offsetY[ix][iy] = constrain(offsetY[ix][iy], -5, 5);
          
          ArrayList<PVector> rama = ramas.get(index);
          
          // Crecimiento de la línea random
          if (frameCount % 2 == 0) {
            PVector ultimo = rama.get(rama.size() - 1);
            float angulo = random(TWO_PI);
            float distancia = random(3, 10);
            float nuevaRamaX = ultimo.x + cos(angulo) * distancia;
            float nuevaRamaY = ultimo.y + sin(angulo) * distancia;
            
            if (abs(nuevaRamaX) > 150 || abs(nuevaRamaY) > 150) {
              rama.clear();
              rama.add(new PVector(0, 0));
            } else {
              rama.add(new PVector(nuevaRamaX, nuevaRamaY));
            }
          }
          
          if (rama.size() > 60) {
            rama.remove(0);
          }
          
          // Dibujar la línea
          for (int k = 1; k < rama.size(); k++) {
            PVector p1 = rama.get(k-1);
            PVector p2 = rama.get(k);
            float grosor = map(k, 0, rama.size(), 2, 0.5);
            float opacidad = map(k, 0, rama.size(), 50, 200);
            
            strokeWeight(grosor);
            if (esVioleta) {
              stroke(200, 50, 255, opacidad); // Línea Violeta
            } else {
              stroke(50, 100, 255, opacidad); // Línea Azul
            }
            line(p1.x + nuevoX, p1.y + nuevoY, p2.x + nuevoX, p2.y + nuevoY);
          }
          
          // Dibujar el punto brillante
          fill(r, g, b, 200);
          noStroke();
          ellipse(nuevoX, nuevoY, step * 0.6, step * 0.6);
          
        } else {
          // Puntos de fondo tenues
          fill(r, g, b, 20);
          noStroke();
          ellipse(x, y, step * 0.4, step * 0.4);
        }
      }
      index++;
    }
  }
  
  println("Puntos (Violetas/Azules): " + contadorVioletas);
}