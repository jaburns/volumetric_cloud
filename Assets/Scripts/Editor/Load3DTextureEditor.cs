using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(Load3DTexture))]
public class Load3DTextureEditor : Editor
{
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        if (GUILayout.Button("Load")) {
            (target as Load3DTexture).Load();
        }
    }
}
