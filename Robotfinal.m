clc,clear ,close all;
a=arduino('COM5','uno','Libraries','servo');

%conexiones del servo con matlab , a (arduino ) y D- con que - es el pin en el que esta conectado
s1 = servo(a,'D13');%base
s2 = servo(a, 'D8');%gatillo
s3 = servo(a, 'D10');%direecion
configurePin(a,'D2', 'DigitalOutput');
configurePin(a,'D4','DigitalOutput');
configurePin(a,'D6','DigitalOutput');

configurePin(a,'D5','DigitalOutput');


%posiciones iniciales del servo
posicionbase = 1;
writePosition(s3,1);%posicion inicial de la direction vertical
writePosition(s2,0.6);%gatillo 0.2 abre 0.6 cierra
writePosition(s1,1);


objects = imaqfind;
delete(objects);
vid=webcam(2);%input de la camara web USB
cam = imaqhwinfo;

preview(vid);%previsualicacion de lo que ve la camara en todo momento , para calibrar


pause(0.2);

%Empezamos con el bucle for el cual sera el que dictamine cuantos movimientos hace el robot y cuantas imagenes toma 
    for T=1:8 

	%lee el voltage del pin A0 el cual es el del sensor de luz , si es mas pequeño que 2 lo enciende y lo apaga diciendo que no detecta luz
    voltage = readVoltage(a, 'A0');
    if voltage <2
        writeDigitalPin(a, 'D5', 1);
        pause(2);
        writeDigitalPin(a, 'D5', 0);
       
    end
    pause(1);
    im=snapshot(vid);%foto instantanea  de la webcam  
    imshow(im)
	%Radio minimo y maximo de la circunferencia que detectara el programa
    Rmin = 50; Rmax = 200;
	%funcion mas importante del porgrama , deteecion de figuras redondas , el metodo 'dark' puede ser cambiado por brightness ,el cual el dark 
	%lo que hace es detectar formas circulares mas oscuras que el fondo y brightness mas claras que el fondo 
	%el numero en este caso 0.88 es la sensivilidad en la cual detectara los circulos , contra mas le pongas mas facil lo detectara , puedes tocarlo 
	%hasta seleccionar uno idoneo
	%Esto devuelve la posicion de x e y donde esta el centro de la esfera y su radio 
    [centersBright, radiiBright] = imfindcircles(im,[Rmin Rmax],'ObjectPolarity','dark','Sensitivity',0.88);
   

   
   %mira si la variable radiiBright esta vacia o no  si esta vacia es que no a detectado ningun circulo 
    if( isempty(radiiBright))
        writePosition(s3,1);
        pause(1);
		%le coloca 0.1 mas a la posicion de la base para que gire el robot en busqueda de esferas
        writePosition(s1,posicionbase-0.1*T);       
        
    else
	%te muestra por camara el circulo encontrado
        viscircles(centersBright, radiiBright,'Color','b');
       
        pause(2);

        
	%Te muestra en la camara el punto medio
        hold on;
        plot(640/2,480/2,'or','LineWidth',2,'MarkerSize',10); 
        
       
        
        
        
        centx =  abs(centersBright(1,1) - 320) ;
        centy =  abs(centersBright(1,2) - 240);
        
		
		%Hace distancia euclidia con el centro y mira si sumandole el radio el punto medio esta dentro de la circunferencia 
        if(sqrt(centx^2 + centy^2) <= radiiBright/2)
         

		%pone a funcionar el motor dc hacia un lado recogiendo el cable 		 
        writeDigitalPin(a,'D2',1);
        writeDigitalPin(a,'D4',1);
        writeDigitalPin(a,'D6',0);

		
		%Hace una pausa esperando a que carge en el rollo todo el cable y activa el servo del gatillo para que cierre
        pause(15);
        writePosition(s2,0.2);
        
        pause(15);
       %para el motor dc
        writeDigitalPin(a,'D2',0);
        writeDigitalPin(a,'D4',0);
        writeDigitalPin(a,'D6',0);

        
        pause(1);
	%pone a funcionar el motor dc hacia el otro lado destensando todo el  cable 
        writeDigitalPin(a,'D2',1);
        writeDigitalPin(a,'D4',0);
        writeDigitalPin(a,'D6',1);

        pause(15);

        w %para el motor dcriteDigitalPin(a,'D2',0);
        writeDigitalPin(a,'D4',0);
        writeDigitalPin(a,'D6',0);

	%Soltar el gatillo para disparar 
        pause(1);
        writePosition(s2,0.6);
       

	   
	   %Todo este cogido es un intento para poder mover el servo y colocar la camara justo en el medio de la diana , pero los servos al ser tan imprecisos nos es imposible , si 
	   %teneis servos mas precisos se puede utilizar perfectamente 
	   
	   
        %end
		%Formula para saber cuanto 1 grado movido desde el arduino cuanta distancia real se movera en la camara	
        %1pixel 1mm
        %D = (168/radiiBright)*100;
        %per= 2*pi*D;
        %disminang=(per*18)/360;
       %calculo de pasar la distancia a grados 
        %centxp = centx*0.1;
        %centyp = centy*0.1;
        %display(centxp);
        %display(disminang);
		%comprobaciones si  la diana se encuentra derecha  o izquierda del centro  
        %if (centxp > disminang)           
         %   p =floor(centxp/disminang);
          %  display(p);
        %elseif (centxp < disminang)
         % posac = readPosition(s1);  
          %writePosition(s1,1);
          %pause(2);
		  %Colocacion al servo la distancia actual menos la distancia calculada 
          %writePosition(s1,posac-0.1);
          %pause(2);
        %elseif (centyp > disminang)
         %   p = floorc(centyp/disminang);
          %  display(p);
        %elseif (centyp < disminang)
         %   poscac = readPosition(s1);
          %  writePosition(s1,1);
           % pause(2);
            %writePosition(s1,posac-0.1);
            %pause(2);
        %end
        
        
        
       
    end    
    end
    




