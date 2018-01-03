using UnityEngine;

public class Rotate : MonoBehaviour 
{
    [SerializeField] Vector3 euler;

    void Update()
    {
        transform.rotation *= Quaternion.Euler(euler * Time.deltaTime);
    }
}
