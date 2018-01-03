using UnityEngine;

public class Load3DTexture : MonoBehaviour
{
    [SerializeField] Texture2D gridTexture;
    [SerializeField] int cellCountX;
    [SerializeField] int cellCountY;
    [SerializeField] string textureUniformName;

    private void Awake()
    {
        Load();
    }

    public void Load()
    {
        float softWidth = gridTexture.width / cellCountX;
        float softHeight = gridTexture.height / cellCountY;

        int width = (int)softWidth;
        int height = (int)softHeight;
        int depth = cellCountX * cellCountY;

        var texture3d = new Texture3D(width, height, depth, TextureFormat.ARGB32, false);
        var colors = new Color[width * height * depth];

        for (int x = 0; x < width; x++) {
            for (int y = 0; y < height; y++) {
                for (int z = 0; z < depth; z++) {
                    var c = gridTexture.GetPixelBilinear(
                        ((float)x/width  + (float)(z%cellCountX)) / cellCountX,
                        ((float)y/height + (float)(z/cellCountY)) / cellCountY
                    );
                    colors[x + (y * width) + (z * width * height)] = c;
                }
            }
        }

        texture3d.wrapMode = TextureWrapMode.Clamp;
        texture3d.SetPixels(colors);
        texture3d.Apply();

        GetComponent<Renderer>().sharedMaterial.SetTexture(textureUniformName, texture3d);
    }
}
