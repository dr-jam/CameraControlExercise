using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Obscura
{
    public class PushBoxCamera : AbstractCameraController
    {
        [SerializeField] public Vector2 topLeft;
        [SerializeField] public Vector2 bottomRight;
        private Camera managedCamera;
        private LineRenderer cameraLineRenderer;

        private void Awake()
        {
            managedCamera = gameObject.GetComponent<Camera>();
            cameraLineRenderer = gameObject.GetComponent<LineRenderer>();
        }

        //Use the LateUpdate message to avoid setting the camera's position before
        //GameObject locations are finalized.
        void LateUpdate()
        {
            var targetPosition = this.Target.transform.position;
            var cameraPosition = managedCamera.transform.position;

            if (targetPosition.y >= cameraPosition.y + topLeft.y)
            {
                cameraPosition = new Vector3(cameraPosition.x, targetPosition.y - topLeft.y, cameraPosition.z);
            }

            if (targetPosition.y <= cameraPosition.y + bottomRight.y)
            {
                cameraPosition = new Vector3(cameraPosition.x, targetPosition.y- bottomRight.y, cameraPosition.z);
            }

            if (targetPosition.x >= cameraPosition.x + bottomRight.x)
            {
                cameraPosition = new Vector3(targetPosition.x - bottomRight.x, cameraPosition.y, cameraPosition.z);
            }

            if (targetPosition.x <= cameraPosition.x + topLeft.x)
            {
                cameraPosition = new Vector3(targetPosition.x- topLeft.x, cameraPosition.y, cameraPosition.z);
            }

            managedCamera.transform.position = cameraPosition;

            if (this.DrawLogic)
            {
                cameraLineRenderer.enabled = true;
                DrawCameraLogic();
            }
            else
            {
                cameraLineRenderer.enabled = false;
            }
        }

        public override void DrawCameraLogic()
        {
            var z = this.Target.transform.position.z - this.managedCamera.transform.position.z;

            cameraLineRenderer.positionCount = 5;
            cameraLineRenderer.useWorldSpace = false;
            cameraLineRenderer.SetPosition(0, new Vector3(topLeft.x, topLeft.y, z));
            cameraLineRenderer.SetPosition(1, new Vector3(bottomRight.x, topLeft.y, z));
            cameraLineRenderer.SetPosition(2, new Vector3(bottomRight.x, bottomRight.y, z));
            cameraLineRenderer.SetPosition(3, new Vector3(topLeft.x, bottomRight.y, z));
            cameraLineRenderer.SetPosition(4, new Vector3(topLeft.x, topLeft.y, z));
        }
    }
}
