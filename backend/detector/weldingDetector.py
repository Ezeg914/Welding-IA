import os
import base64
from io import BytesIO
from PIL import Image
from ultralytics import YOLO
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle

model_path = '/home/ezequiel/Welding-IA/backend/detector/models/welding_v1_aug15/weights/best.pt'

output_dir = "/home/ezequiel/Welding-IA/output_images"
os.makedirs(output_dir, exist_ok=True)

try:
    print(f"Cargando modelo desde: {model_path}")
    model = YOLO(model_path)
    print("Modelo cargado correctamente.")
except Exception as e:
    raise RuntimeError(f"Error al cargar el modelo YOLO: {e}")

def analyze_image(image_data: bytes, img_size=640, conf=0.19) -> str:
    temp_image_path = os.path.join(output_dir, "temp_image.jpg")
    output_image_path = os.path.join(output_dir, "processed_image.jpg")

    try:
        print(f"Recibiendo {len(image_data)} bytes de datos de imagen.")
        with Image.open(BytesIO(image_data)) as img:
            print(f"Formato original de la imagen: {img.format}")
            img_resized = img.resize((img_size, img_size), Image.Resampling.LANCZOS)
            img_resized.save(temp_image_path)
            print(f"Imagen redimensionada guardada en: {temp_image_path}")

        print("Iniciando detección con YOLO...")
        results = model(temp_image_path, conf=conf)
        print(f"Detecciones realizadas: {len(results)}")

        
        for result in results:
           
            img = Image.open(temp_image_path)
            fig, ax = plt.subplots(1, figsize=(12, 8))
            ax.imshow(img)


            for box in result.boxes:
                x1, y1, x2, y2 = box.xyxy[0].numpy()
                cls = int(box.cls)
                conf = box.conf[0].item()  
                label = result.names[cls]  

              
                if label == "Good Weld":
                    color = "green"
                elif label == "Bad Weld":
                    color = "red"
                else:
                    color = "orange"  

                
                rect = Rectangle((x1, y1), x2 - x1, y2 - y1, linewidth=2, edgecolor=color, facecolor='none')
                ax.add_patch(rect)
                ax.text(x1, y1 - 10, f"{label} {conf:.2f}", color=color, fontsize=12, backgroundcolor="white")

            
            plt.axis('off')
            plt.savefig(output_image_path, bbox_inches='tight', pad_inches=0)
            plt.close(fig)

        print(f"Imagen procesada guardada en: {output_image_path}")

        
        with open(output_image_path, "rb") as f:
            processed_image_data = f.read()
            processed_image_base64 = base64.b64encode(processed_image_data).decode('utf-8')
            print(f"Imagen procesada convertida a base64, longitud: {len(processed_image_base64)}")
        
        return processed_image_base64

    except Exception as e:
        print(f"Error en analyze_image: {e}")
        raise RuntimeError(f"Error al procesar la imagen: {e}")


# import os
# import base64
# from io import BytesIO
# from PIL import Image
# from ultralytics import YOLO

# model_path = '/home/ezequiel/Welding-IA/backend/detector/models/welding_v1_aug15/weights/best.pt'

# output_dir = "/home/ezequiel/Welding-IA/output_images"

# os.makedirs(output_dir, exist_ok=True)


# try:
#     print(f"Cargando modelo desde: {model_path}")
#     model = YOLO(model_path)
#     print("Modelo cargado correctamente.")
# except Exception as e:
#     raise RuntimeError(f"Error al cargar el modelo YOLO: {e}")

# def analyze_image(image_data: bytes, img_size=640, conf=0.10) -> str:
#     temp_image_path = os.path.join(output_dir, "temp_image.jpg")
#     output_image_path = os.path.join(output_dir, "processed_image.jpg")

#     try:
#         print(f"Recibiendo {len(image_data)} bytes de datos de imagen.")
#         with Image.open(BytesIO(image_data)) as img:
#             print(f"Formato original de la imagen: {img.format}")
#             img_resized = img.resize((img_size, img_size), Image.Resampling.LANCZOS)
#             img_resized.save(temp_image_path)
#             print(f"Imagen redimensionada guardada en: {temp_image_path}")

#         print("Iniciando detección con YOLO...")
#         results = model(temp_image_path, conf=conf)
#         print(f"Detecciones realizadas: {len(results)}")

#         for result in results:
#             result.plot(save=True, filename=output_image_path)
#         print(f"Imagen procesada guardada en: {output_image_path}")

#         with open(output_image_path, "rb") as f:
#             processed_image_data = f.read()
#             processed_image_base64 = base64.b64encode(processed_image_data).decode('utf-8')
#             print(f"Imagen procesada convertida a base64, longitud: {len(processed_image_base64)}")
        
#         return processed_image_base64

#     except Exception as e:
#         print(f"Error en analyze_image: {e}")
#         raise RuntimeError(f"Error al procesar la imagen: {e}")

