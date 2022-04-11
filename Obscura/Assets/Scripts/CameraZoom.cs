using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
public class CameraZoom : MonoBehaviour
{
    [SerializeField] private float cameraSpeed = 2.0f;

    private Camera managedCamera;

    private void Awake()
    {
        this.managedCamera = this.gameObject.GetComponent<Camera>();
    }

    // void Update()
    // {
    //     this.managedCamera.transform.Translate(0f, 0f, Input.GetAxis("Vertical2"));
    // }
}
